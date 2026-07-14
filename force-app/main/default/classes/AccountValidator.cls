/**
 * @description Service class that validates Account records before insert.
 * Ensures BillingCountry is populated and Industry is set, in a bulk-safe
 * manner so it can be called from triggers or invocable contexts processing
 * many records at once.
 */
public with sharing class AccountValidator {

    /**
     * @description Custom exception thrown when one or more Account records
     * fail validation. The message aggregates all failures found in the batch.
     */
    public class AccountValidationException extends Exception {}

    /**
     * @description Validates a list of Account records prior to insert, checking
     * that BillingCountry is not blank and Industry is populated. Collects all
     * failures across the batch and throws a single AccountValidationException
     * describing every invalid record, rather than failing on the first error.
     * @param accounts The list of Account records to validate.
     * @throws AccountValidationException if any record fails validation.
     */
    public static void validateBeforeInsert(List<Account> accounts) {
        if (accounts == null || accounts.isEmpty()) {
            return;
        }

        List<String> errors = new List<String>();

        for (Account acc : accounts) {
            List<String> recordErrors = new List<String>();

            if (String.isBlank(acc.BillingCountry)) {
                recordErrors.add('BillingCountry is required.');
            }

            if (String.isBlank(acc.Industry)) {
                recordErrors.add('Industry is required.');
            }

            if (!recordErrors.isEmpty()) {
                String identifier = String.isNotBlank(acc.Name) ? acc.Name : 'Unnamed Account';
                errors.add(identifier + ': ' + String.join(recordErrors, ' '));
            }
        }

        if (!errors.isEmpty()) {
            throw new AccountValidationException(String.join(errors, ' | '));
        }
    }
}