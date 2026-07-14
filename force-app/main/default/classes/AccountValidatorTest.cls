@isTest
private class AccountValidatorTest {

    @isTest
    static void testValidateBeforeInsert_allValid_doesNotThrow() {
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Acme Inc', BillingCountry = 'USA', Industry = 'Technology'),
            new Account(Name = 'Globex Corp', BillingCountry = 'Canada', Industry = 'Manufacturing')
        };

        Test.startTest();
        AccountValidator.validateBeforeInsert(accounts);
        Test.stopTest();

        System.assert(true, 'Validation should pass without throwing for valid Accounts.');
    }

    @isTest
    static void testValidateBeforeInsert_missingBillingCountry_throws() {
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Missing Country', Industry = 'Technology')
        };

        AccountValidator.AccountValidationException caught;
        Test.startTest();
        try {
            AccountValidator.validateBeforeInsert(accounts);
        } catch (AccountValidator.AccountValidationException e) {
            caught = e;
        }
        Test.stopTest();

        System.assertNotEquals(null, caught, 'Expected an AccountValidationException.');
        System.assert(caught.getMessage().contains('BillingCountry is required.'));
    }

    @isTest
    static void testValidateBeforeInsert_missingIndustry_throws() {
        List<Account> accounts = new List<Account>{
            new Account(Name = 'Missing Industry', BillingCountry = 'USA')
        };

        AccountValidator.AccountValidationException caught;
        Test.startTest();
        try {
            AccountValidator.validateBeforeInsert(accounts);
        } catch (AccountValidator.AccountValidationException e) {
            caught = e;
        }
        Test.stopTest();

        System.assertNotEquals(null, caught, 'Expected an AccountValidationException.');
        System.assert(caught.getMessage().contains('Industry is required.'));
    }

    @isTest
    static void testValidateBeforeInsert_bulkMixedValidity_aggregatesErrors() {
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 50; i++) {
            accounts.add(new Account(Name = 'Valid ' + i, BillingCountry = 'USA', Industry = 'Technology'));
        }
        accounts.add(new Account(Name = 'Invalid Record'));

        AccountValidator.AccountValidationException caught;
        Test.startTest();
        try {
            AccountValidator.validateBeforeInsert(accounts);
        } catch (AccountValidator.AccountValidationException e) {
            caught = e;
        }
        Test.stopTest();

        System.assertNotEquals(null, caught, 'Expected an AccountValidationException for the invalid record in the batch.');
        System.assert(caught.getMessage().contains('Invalid Record'));
        System.assert(caught.getMessage().contains('BillingCountry is required.'));
        System.assert(caught.getMessage().contains('Industry is required.'));
    }

    @isTest
    static void testValidateBeforeInsert_nullOrEmptyList_doesNotThrow() {
        Test.startTest();
        AccountValidator.validateBeforeInsert(null);
        AccountValidator.validateBeforeInsert(new List<Account>());
        Test.stopTest();

        System.assert(true, 'Null or empty input should be a no-op.');
    }

    @isTest
    static void testValidateBeforeInsert_unnamedAccountFailure_usesFallbackIdentifier() {
        List<Account> accounts = new List<Account>{ new Account() };

        AccountValidator.AccountValidationException caught;
        Test.startTest();
        try {
            AccountValidator.validateBeforeInsert(accounts);
        } catch (AccountValidator.AccountValidationException e) {
            caught = e;
        }
        Test.stopTest();

        System.assertNotEquals(null, caught, 'Expected an AccountValidationException.');
        System.assert(caught.getMessage().contains('Unnamed Account'));
    }
}