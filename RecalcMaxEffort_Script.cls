//Anonymous Apex Script that will recalculate Max Effort based on the % Complete and Project Line Planned Start and Planned End Dates.

//Plug SHORT 15 character ID of the Accorto Project in to the ProjectID variable here... for example, HAF: HAF: a0u4V000007eOhn
String ProjectID = 'a0u000000000000';

//Rest of the code...
accorto__Project_Line_Sharing__c[] updates = new List<accorto__Project_Line_Sharing__c>();
Double prevMaxEffort = 0;

  accorto__Project_Line_Sharing__c[] PLAs = [
    SELECT Id, accorto__ProjectId__c, Planned_Start_Date__c, Planned_End_Date__c, accorto__MaxEffort__c, accorto__Percent__c, Sum_of_T_E_Items__c
    FROM accorto__Project_Line_Sharing__c
    WHERE accorto__ProjectId__c = :ProjectID
    ];

for(accorto__Project_Line_Sharing__c allocation : PLAs) {
  Date startDate = Date.today();
  Date endDate = Date.today();
  if(allocation.Planned_Start_Date__c != null && allocation.Planned_Start_Date__c > Date.today()) {
    startDate = allocation.Planned_Start_Date__c;
  }
  if(allocation.Planned_End_Date__c != null && allocation.Planned_End_Date__c > Date.today()) {
    endDate = allocation.Planned_End_Date__c;
  }
  prevMaxEffort = allocation.accorto__MaxEffort__c;
  if(allocation.accorto__Percent__c == null) { allocation.accorto__Percent__c = 0; }
  System.debug(startDate);
  System.debug(endDate);
  Integer duration = startDate.daysBetween(endDate);
  if(allocation.accorto__Percent__c == null) {allocation.accorto__Percent__c = 0; }
  if(allocation.Sum_of_T_E_Items__c == null) {allocation.Sum_of_T_E_Items__c = 0; }
  allocation.accorto__MaxEffort__c = (duration * (allocation.accorto__Percent__c   / 100) * 40 / 7)  + allocation.Sum_of_T_E_Items__c;
  if(allocation.accorto__MaxEffort__c != 0) {
    System.debug('Will update PLA ID ' + allocation.Id + ' from previous Max Effort of ' + prevMaxEffort + ' to ' + allocation.accorto__MaxEffort__c + '.');
    updates.add(allocation);
  }
}
System.debug('Applying the following updates: ' + updates);
update updates;
