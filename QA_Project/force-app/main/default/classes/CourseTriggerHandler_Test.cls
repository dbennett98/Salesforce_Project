@isTest
private class CourseTriggerHandler_Test {
    
    @TestSetup
    private static void testSetupObjectDataFactory(){
        Opportunity testCourse = new Opportunity (Name = 'Test Course1',
                                                    Status__c = 'Scheduled');
        insert testCourse;
        System.debug([SELECT Id,Name from Opportunity]);    
        Profile p = [SELECT Id from Profile WHERE Name = 'System Administrator'];
        User u = [SELECT Id FROM User WHERE profileId = :p.Id LIMIT 1];
                         
    }

    @isTest
    private static void insertCourseSharingSuccess(){
        List <Opportunity> courses = [SELECT Id FROM Opprtunity LIMIT 1];
        Opportunity course = courses[0];

        OpportunityShare = courseShare = new OpportunityShare(
            opportunityId = course.Id,
            UserOrGroupId = courses.InstructorUserId__c,
            OpportunityAccesslevel = 'Read');

            Test.startTest();
            Database.SaveResult insertionResult = Database.insert(OpportunityShare,false);
            Test.stopTest();

    Integer errorCount = 0;

    if(!insertionResult.isFail()) {
        if(insertionResult.getErrors()[0].getMessage()==
        'DML Exception'){
            System.debug('Received Error Message');
        }
        ++errorCount;
    }
    System.assertEquals(0,errorCount);
    }
}
