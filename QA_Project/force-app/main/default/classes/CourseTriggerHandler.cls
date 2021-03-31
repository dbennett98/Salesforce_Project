public with sharing class CourseTriggerHandler {
    public CourseTriggerHandler() {
    }

    public static void CourseSharing(List<Opportunity> triggerNew,Map<Id, Opportunity> oldMap, Boolean isInsert,Boolean isUpdate){
        
        System.debug('Starting the Sharing logic');
    // List of share records to insert
    List<OpportunityShare> recordShare = new List<OpportunityShare>();

    // List of share records to delete
    List <OpportunityShare> recordShareDelete = new List <OpportunityShare>();

    // Map of Course Id to Instructor Id
    Map <Id,Id> coursesToInstructorMap = new Map<Id,Id>();

    //Instaniating ConnectAPI elements
    ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();

    ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();

    ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();

    ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();

    // loop throuhg all records in the trigger
    for (Opportunity courses: triggerNew){
        // Check if record is insert
        if(isInsert || courses.InstructorUserId__c != oldMap.get(courses.Id).InstructorUserId__c){
            if (courses.InstructorUserId__c !=null){
            OpportunityShare courseShare = new OpportunityShare(
                opportunityId = courses.Id ,
                UserOrGroupId = courses.InstructorUserId__c ,
                OpportunityAccessLevel = 'Read'
            );
                recordShare.add(courseShare);
            }
        }
    
        if (isUpdate){
            // See if Instructor has changed
            if(courses.InstructorUserId__c != oldMap.get(courses.Id).InstructorUserId__c){
                //Add to map of Instructor Changes
                System.debug('courses.InstructorUserId__c is: '+ courses.InstructorUserId__c);
                coursesToinstructorMap.put(courses.id,courses.InstructorUserId__c);
            }
        }
    }
    if (coursesToInstructorMap.size() > 0){
        System.debug('coursesToInstructorMap is: ' + coursesToInstructorMap);
        for (OpportunityShare courseShare :[SELECT UserOrGroupId,RowCause,opportunityId,Id,OpportunityAccessLevel
                                                FROM OpportunityShare
                                                WHERE opportunityId IN :coursesToInstructorMap.keySet()
                                                AND RowCause = 'Manual']){
            if (coursesToInstructorMap.get(courseShare.opportunityId) != courseShare.UserOrGroupId){
                recordShareDelete.add(courseShare);
            }
         } 
    }
    try{
        if (recordShare.size() >0){
            insert recordShare;
        }
        if (recordShareDelete.size() >0){
            delete recordShareDelete;
        }
    }  catch (System.DmlException ex) {
        System.debug(ex);
    }


    //Chatter Feed item code
    //messageBodyInput.messageSegments = new List <ConnectAPI.MessageSegmentInput>();
    //mentionSegmentInput.id = 1;
    //messageBodyInput.messageSegements.add(mentionSegmentInput);
    
    //textSegmentInput.text = 'An item has been added to your calendar';
    //messageBodyInput.messageSegments.add(textSegmentInput);

    //feedItemInput.body = messageBodyInput;
    //feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
    //feedItemInput.subjectId = 1;
    
    }
    

    public static void CourseEvent (List <Opportunity> triggerNew, Map<Id, Opportunity> oldMap, Boolean isInsert, Boolean isUpdate){
        //Events to add list
        List<Event> opportunityEvent = new List <Event> ();
        //Events to delete list
        List <Event> opportunityEventDel = new List <Event> ();

        List <Id> delId = new List <Id> ();

        List <Id> chatterId = new List <Id> ();

        Map <Id,Id> coursesToInstructorMap = new Map<Id,Id>();

        for (Opportunity courses: triggerNew){

            if (isInsert|| courses.InstructorUserId__c != oldMap.get(courses.Id).InstructorUserId__c){
                Event courseEvent = new Event (
                    OwnerId = courses.InstructorUserId__c,
                    StartDateTime = courses.Start_Date__c,
                    EndDateTime = courses.CloseDate,
                    Subject = courses.EventSubject__c,
                    WhatId = courses.id,
                    Location = courses.Location__c
                    
                );
                if(courses.StageName == 'Cancelled'){
                    delId.add(courses.id);
                }else{
                opportunityEvent.add(courseEvent);
                chatterId.add(courses.InstructorUserId__c);
                }
            }
            if (isUpdate){
                // See if Instructor has changed
                if(courses.InstructorUserId__c != oldMap.get(courses.Id).InstructorUserId__c){
                    //Add to map of Instructor Changes
                    System.debug('courses.InstructorUserId__c is: '+ courses.InstructorUserId__c);
                    coursesToinstructorMap.put(courses.id,courses.InstructorUserId__c);
                }
            }
        }
        if (coursesToInstructorMap.size() > 0){
            System.debug('coursesToInstructorMap is: ' + coursesToInstructorMap);
            for (Event courseEvent :[SELECT OwnerId,WhatId
                                                    FROM Event
                                                    WHERE WhatId IN :coursesToInstructorMap.keySet()
                                                    ]){
                if (coursesToInstructorMap.get(courseEvent.WhatId) != courseEvent.ownerId){
                    delId.add(courseEvent.WhatId);
                }
             } 
        }
        
           if (delId.size()>0){
           for(List<Event> eventsToDelete : [SELECT Id, StartDateTime, EndDateTime,Location,WhatId,Subject
                                    FROM Event
                                    WHERE WhatId IN :delId]){
            for(Event eventDelete: eventsToDelete)
            opportunityEventDel.add(eventDelete);
                                    }
           }
            insert(opportunityEvent);
            Database.delete(opportunityEventDel,false);
            if(isInsert){
            ConnectAPI.FeedElement feedElement = ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(),chatterId[0],ConnectApi.FeedElementType.FeedItem, 'An even has been added to your Calendar.');
        }
    }
    }

