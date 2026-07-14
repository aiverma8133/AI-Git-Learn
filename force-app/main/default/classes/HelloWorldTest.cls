@isTest
private class HelloWorldTest {

    @isTest
    static void testSayHello() {
        Test.startTest();
        HelloWorld.sayHello();
        Test.stopTest();
    }
}