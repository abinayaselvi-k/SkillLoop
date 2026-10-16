const { onDocumentCreated, onDocumentUpdated } = require('firebase-functions/v2/firestore');
const { logger } = require('firebase-functions');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const { initializeApp } = require('firebase-admin/app');

initializeApp();

const db = getFirestore();

/**
 * Updates only the reviewed student's aggregate after an immutable review is
 * created. The Flutter client cannot write these protected profile fields.
 */
exports.updateProfileRating = onDocumentCreated('reviews/{reviewId}', async (event) => {
  const review = event.data.data();
  if (!review || typeof review.revieweeId !== 'string' || typeof review.rating !== 'number') {
    logger.warn('Ignoring malformed review', { reviewId: event.params.reviewId });
    return;
  }

  const profileRef = db.collection('users').doc(review.revieweeId);
  const eventRef = db.collection('profileAggregationEvents').doc(event.id);
  await db.runTransaction(async (transaction) => {
    const eventRecord = await transaction.get(eventRef);
    if (eventRecord.exists) return;

    const profile = await transaction.get(profileRef);
    if (!profile.exists) {
      logger.warn('Review target profile does not exist', { revieweeId: review.revieweeId });
      transaction.set(eventRef, { type: 'review', ignored: true, createdAt: FieldValue.serverTimestamp() });
      return;
    }

    const data = profile.data();
    const reviewCount = Number.isInteger(data.reviewCount) ? data.reviewCount : 0;
    const averageRating = typeof data.averageRating === 'number' ? data.averageRating : 5;
    const nextCount = reviewCount + 1;
    const nextAverage = ((averageRating * reviewCount) + review.rating) / nextCount;

    transaction.update(profileRef, {
      reviewCount: nextCount,
      averageRating: Number(nextAverage.toFixed(1)),
      updatedAt: FieldValue.serverTimestamp(),
    });
    transaction.set(eventRef, {
      type: 'review',
      reviewId: event.params.reviewId,
      createdAt: FieldValue.serverTimestamp(),
    });
  });
});

/**
 * Counts a completed exchange exactly once: only the transition from accepted
 * to completed triggers this function. Both participants receive one count.
 */
exports.incrementCompletedExchangeCounts = onDocumentUpdated(
  'exchangeRequests/{requestId}',
  async (event) => {
    const before = event.data.before.data();
    const after = event.data.after.data();
    if (before.status === 'completed' || after.status !== 'completed') return;

    const participantIds = [after.senderId, after.receiverId];
    if (participantIds.some((id) => typeof id !== 'string') || participantIds[0] === participantIds[1]) {
      logger.warn('Ignoring malformed exchange request', { requestId: event.params.requestId });
      return;
    }

    const eventRef = db.collection('profileAggregationEvents').doc(event.id);
    await db.runTransaction(async (transaction) => {
      const eventRecord = await transaction.get(eventRef);
      if (eventRecord.exists) return;

      for (const userId of participantIds) {
        transaction.update(db.collection('users').doc(userId), {
          completedExchanges: FieldValue.increment(1),
          updatedAt: FieldValue.serverTimestamp(),
        });
      }
      transaction.set(eventRef, {
        type: 'completedExchange',
        exchangeRequestId: event.params.requestId,
        createdAt: FieldValue.serverTimestamp(),
      });
    });
  },
);
