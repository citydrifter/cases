# Testing Scenarios

## 1. Happy Path

Submit a valid lead payload.

Expected result:

- raw event is inserted
- CRM mock returns success
- lead is inserted into `leads`
- raw event becomes `completed`
- Telegram success notification is sent
- workflow logs are created

## 2. Duplicate Event

Submit the same payload twice with the same `submission_id`.

Expected result:

- second event is detected as duplicate
- processing stops
- duplicate event log is created

## 3. Duplicate Lead

Submit a new payload with a new `submission_id`, but with an existing email.

Expected result:

- raw event is inserted
- lead lookup finds existing email
- event becomes `duplicate_lead`
- lead is not created again

## 4. CRM Failure

Set Mock CRM failure mode to true and submit a valid payload.

Expected result:

- raw event is inserted
- CRM mock returns error response
- event becomes `failed`
- error message is stored
- failure log is created

## 5. Retry Success

After CRM failure, set Mock CRM retry mode to success and run retry workflow.

Expected result:

- failed event becomes `retrying`
- lead data is rebuilt from JSONB payload
- CRM mock succeeds
- lead is inserted
- event becomes `completed`
- retry success log is created

## 6. Retry Failure

Keep Mock CRM retry mode as failure and run retry workflow.

Expected result:

- event becomes `retrying`
- CRM retry fails
- retry_count increments
- next_retry_at is set
- event returns to `failed`

## 7. Retry Limit Reached

Run failed retries until retry_count reaches the configured limit.

Expected result:

- event is moved to `manual_review`
- manual review log is created
- Telegram manual review notification is sent

## 8. Invalid Payload

Submit a payload with missing email.

Expected result:

- raw event is inserted
- event becomes `manual_review`
- error message contains `missing_email`
- validation failed log is created
- Telegram manual review notification is sent

## 9. Manual Review Resolve

Use the manual review resolve webhook with an event ID.

Expected result:

- event moves from `manual_review` to `failed`
- retry_count resets
- next_retry_at is set to now
- manual_review_resolved log is created
- retry workflow can process the event again

## 10. Daily Monitoring Report

Run the monitoring workflow.

Expected result:

- Telegram receives a system health report
- report includes event counts, leads, retry stats, and recent problem events