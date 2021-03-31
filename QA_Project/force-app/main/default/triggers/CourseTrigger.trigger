trigger CourseTrigger on Opportunity (after insert,after update) {
   
    SWITCH ON Trigger.OperationType{

        WHEN AFTER_UPDATE{
            CourseTriggerHandler.CourseSharing(Trigger.new,Trigger.oldMap,Trigger.isInsert, Trigger.isUpdate);
            CourseTriggerHandler.CourseEvent(Trigger.new, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate);
}
        WHEN AFTER_INSERT{
            CourseTriggerHandler.CourseSharing(Trigger.new,Trigger.oldMap,Trigger.isInsert, Trigger.isUpdate);
            CourseTriggerHandler.CourseEvent(Trigger.new, Trigger.oldMap, Trigger.isInsert, Trigger.isUpdate);
        }
}
}