/*

Controller used for the File Search page.


*/
public with sharing class FileAssociateController {
    
    private Case file;
    
    public Account account {get; private set;}
    
    public boolean correspondentView {get; private set;}
    
    public String firstName { get; set;}
    public String lastName { get; set;}
    public String phone { get; set;}
    public String fileNumber {get; set;}
    public String email {get; set;}
    public String salutation {get;set;}
    
    public List<CorrespondentWrapper> investors {get; private set;}
    public List<FileWrapper> files {get; private set;}
    public List<FileWrapper> files2 {get; private set;}
    
    
    //Status variables
    public boolean investorSearchPerformed {get; private set;}
    public boolean fileSearchPerformed {get; private set;}
    
    //New Search
    public boolean searchOnly {get; private set;}
    public boolean webFile {get; private set;}
    
    public EmailMessageTaskUtilBatch emtu;
    
    //Picklist fields
    public String suffix {get; set;}
    public String correspondentType {get; set;}
    
    /*

Uses the standard Case controller


*/
    public FileAssociateController(ApexPages.StandardController stdController){
        correspondentView = false;
        this.investorSearchPerformed = false;
        this.file = (Case) stdController.getRecord();
        
         //Added for lightning
        if(file.Id != null){
           this.file = [SELECT Id, SuppliedEmail, SuppliedName,OwnerId, Origin, Web_Form_Contact_First_Name__c, Web_Form_Contact_Last_Name__c, 
                     Web_Form_Contact_Title__c,Status,AWD__c, Description,CaseNumber
                     FROM Case 
                     WHERE Id =: file.Id];
        }
                     
        if (file == null || file.id== null) {
            searchOnly = true;
        }
        else {
            searchOnly = false;
        }
        
        if (file.SuppliedEmail != null) {
            email = file.suppliedEmail;
        }
        
        if (file.SuppliedName != null) {
            NameParser parser = new NameParser(file.SuppliedName);
            firstName = parser.firstName;
            lastName = parser.lastName;
        }
        
        if(file.SuppliedName == null && file.Web_Form_Contact_First_Name__c != null){
            firstName = file.Web_Form_Contact_First_Name__c;
        }
        
        if(file.SuppliedName == null && file.Web_Form_Contact_Last_Name__c != null){
            lastName = file.Web_Form_Contact_Last_Name__c;
        }
        
        if (email != null || lastName != null) {
            searchInvestor();
        }
        if(file.origin == 'Web'){
            webFile = true;
        }
        else{
            webFile = false;
        }
        
        //TM_01/15/2015 Correspondent Salutation Edit
        if(searchonly == false) {
            case filevalue = [ select id, Web_Form_Contact_Title__c from Case where id =: file.id limit 1];
            if(filevalue.Web_Form_Contact_Title__c != null){
                salutation = filevalue.Web_Form_Contact_Title__c;
            }
        }
        //TM_01/15/2015 Correspondent Salutation Save
        
        /////////// 
        //DayTime Phone Search Update AM_09/15/2014_AM
        
        if(searchonly == false) {
            Case fileField = [select id, Web_Form_Daytime_Phone__c from Case where id =: file.id Limit 1];
            if(fileField.Web_Form_Daytime_Phone__c != null) {
                phone = fileField.Web_Form_Daytime_Phone__c;
            }
        }
        
        ///////////
    }
    
    
    /*

Simple method to determine whether quick create contact button is enabled.
(only allow after correspondent search has been performed)

*/
    public boolean getAllowQuickCreate() {
        return investorSearchPerformed;// && !isEmpty(firstName) && !isEmpty(lastName) && (!isEmpty(phone) || !isEmpty(email));
    }
    
    /*

Perform the correspondent Search. The results of the search are stored in the investors field.


*/
    private void performInvestorSearch() {
        //Dynamic Apex
        String baseSOQL = 'Select Id, Name, PersonContactId,Full_Correspondent_Name__pc, primary_email__pc, Personal_Email__pc, ' +
            'Other_Email__pc, Phone,PersonHomePhone, PersonOtherPhone, PersonAssistantPhone, Correspondent_Type__pc, personmailingstate, Account.ACTS_Flag__pc from Account where ';
        
        LogicalExpression expressions = new LogicalExpression(LogicalExpression.OPERATOR_AND);
        
        if (firstName !=  null && firstName.trim().length() > 0) {
            expressions.addExpression((new ConditionalExpression('firstName',firstName.trim(),ConditionalExpression.OPERATOR_LIKE,'STRING',FALSE)).buildSOQL());
        }
        
        //Email fields
        List<String> clauses = new List<String>();
        if (email != null && email.trim().length() > 0) {
            email = email.trim();
            //                LogicalExpression emailExpression = new LogicalExpression(LogicalExpression.OPERATOR_OR);
            //                emailExpression.addExpression((new ConditionalExpression('Primary_Email__pc',email,ConditionalExpression.OPERATOR_EQUALS,'STRING',FALSE)).buildSOQL());
            //                emailExpression.addExpression((new ConditionalExpression('Other_Email__pc',email,ConditionalExpression.OPERATOR_EQUALS,'STRING',FALSE)).buildSOQL());
            //                emailExpression.addExpression((new ConditionalExpression('Personal_Email__pc',email,ConditionalExpression.OPERATOR_EQUALS,'STRING',FALSE)).buildSOQL());
            //              System.debug('****** '+emailExpression.buildSOQL());
            //                expressions.addExpression(emailExpression.buildSOQL());
            baseSOQL = baseSOQL+'Primary_Email__pc =\''+email+'\' or Other_Email__pc =\''+email+'\' Or Personal_Email__pc =\''+email+'\'';
        }
        
        //Phone fields
        clauses = new List<String>();
        if (phone != null && phone.trim().length() > 0) {
            phone = phone.trim();
            
            LogicalExpression phoneExpression = new LogicalExpression(LogicalExpression.OPERATOR_OR);
            phoneExpression.addExpression((new ConditionalExpression('Phone',phone,ConditionalExpression.OPERATOR_LIKE,'PHONE',FALSE)).buildSOQL());
            phoneExpression.addExpression((new ConditionalExpression('PersonAssistantPhone',phone,ConditionalExpression.OPERATOR_LIKE,'PHONE',FALSE)).buildSOQL());
            phoneExpression.addExpression((new ConditionalExpression('PersonHomePhone',phone,ConditionalExpression.OPERATOR_LIKE,'PHONE',FALSE)).buildSOQL());
            phoneExpression.addExpression((new ConditionalExpression('PersonMobilePhone',phone,ConditionalExpression.OPERATOR_LIKE,'PHONE',FALSE)).buildSOQL());
            phoneExpression.addExpression((new ConditionalExpression('PersonOtherPhone',phone,ConditionalExpression.OPERATOR_LIKE,'PHONE',FALSE)).buildSOQL());
            
            
            
            //***********************************************************************************************
            if (phone != null && phone.trim().length() == 10) {
                phone = phone.trim();
                
                phoneExpression.addExpression((new ConditionalExpression('Phone',phone,ConditionalExpression.OPERATOR_LIKE,'PHONE',TRUE)).buildSOQL());
                phoneExpression.addExpression((new ConditionalExpression('PersonAssistantPhone',phone,ConditionalExpression.OPERATOR_LIKE,'PHONE',TRUE)).buildSOQL());
                phoneExpression.addExpression((new ConditionalExpression('PersonHomePhone',phone,ConditionalExpression.OPERATOR_LIKE,'PHONE',TRUE)).buildSOQL());
                phoneExpression.addExpression((new ConditionalExpression('PersonMobilePhone',phone,ConditionalExpression.OPERATOR_LIKE,'PHONE',TRUE)).buildSOQL());
                phoneExpression.addExpression((new ConditionalExpression('PersonOtherPhone',phone,ConditionalExpression.OPERATOR_LIKE,'PHONE',TRUE)).buildSOQL());
                
            }
            //*************************************************************************************************
            expressions.addExpression(phoneExpression.buildSOQL());
            
        }
        
        
        //Last Name
        if (lastName != null && lastName.trim().length() > 0) {
            expressions.addExpression((new ConditionalExpression('lastName',lastName.trim(),ConditionalExpression.OPERATOR_LIKE,'STRING',FALSE)).buildSOQL());
        }
        
        expressions.addExpression((new ConditionalExpression('isPersonAccount',true,ConditionalExpression.OPERATOR_EQUALS,'boolean',FALSE)).buildSOQL());
        
        
        String soql = '';
        String soqlSize ='';
        System.debug('##### email '+email);
        if(email != null && email.trim().length() > 0 )
        {
            soql = baseSOQL + ' LIMIT 100';  
            soqlSize =baseSOQL + ' LIMIT 100';
        }
        else
        {
            soql = baseSOQL + expressions.buildSOQL() + ' LIMIT 100';
            soqlSize =baseSOQL + expressions.buildSOQL() + ' LIMIT 110';
        }
        
        System.debug('********# ' + soql);
        List<Account> accounts = Database.query(soql);
        
        //This snippet checks to see how large the query size was and if it's over 100 display a message to users.
        
        
        List<Account> cnt = Database.query(soqlSize);
        system.debug(cnt.size());
        if(cnt!=null&&cnt.size()>100){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'The list of results is over 100 records.  Only the first 100 records are displayed.  Please be more specific in your search criteria.'));
        }
        //*********************************************************************************
        
        if (accounts != null && accounts.size() > 0) {
            investors = new List<CorrespondentWrapper>();
            
            for (Account account: accounts) {
                investors.add(new CorrespondentWrapper(account,email,phone));
            }
        }
        
        //investors = [Select Id, Name, PersonContactId, Primary_Email__pc from Account where lastName = :lastName];
        
        //Clear out the CorrespondentWrapper if there are no results
        if (accounts == null || accounts.size() == 0) {
            investors = null;
        }
        
    }
    
    /*

Investor Search action called directly from the investor search.



*/
    public PageReference searchInvestor() {
        investors = null;
        files = null;
        
        fileSearchPerformed = false;
        investorSearchperformed = false;
        
        //Determine if it is a search by File Number
        if (fileNumber != null && fileNumber.trim().length() > 0) {
            fileSearchPerformed = true;
            
            List<Case> results = null;
            String filenumberSearch = '%' + filenumber + '%';
            if(fileNumber.contains('*')){
                filenumberSearch=filenumberSearch.replace('*', '%');
            }
            
            results = [Select Id, Origin, Owner.Name, CreatedDate, CaseNumber, Description, Subject, Status, Account.Id, Account.Name, Account.PersonContactId,Account.Full_Correspondent_Name__pc, Account.Primary_Email__pc,
                       Account.Phone, Account.Personal_Email__pc, Account.Other_Email__pc, Account.PersonHomePhone, Account.PersonOtherPhone, Account.PersonAssistantPhone,
                       Account.Correspondent_Type__pc, Account.personmailingstate, Account.ACTS_Flag__pc, (Select Id, Subject__c from CaseSubjectAssociations__r) from Case where File_Number__c like :fileNumberSearch and Id != :file.id LIMIT 100];
            //  }
            
            //This snippet checks to see how large the query size was and if it's over 100 display a message to users.
            integer cnt = [select count() from Case where File_Number__c like :fileNumberSearch];
            if(cnt!=null&&cnt>100){
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'The list of results is over 100 records.  Only the first 100 records are displayed.'));
            }
            //*********************************************************************888
            if (results == null || results.size() == 0) {
                files = null;
            }
            else {
                files = wrapFiles(results);
            }
            
            
            //If we have one and only one investor from the file, include this in the investor list
            if (results != null && results.size() == 1) {
                investorSearchPerformed = true;
                Case file = results[0];
                if (file.AccountId != null) {
                    investors = new CorrespondentWrapper[] {new CorrespondentWrapper(file.Account,email,phone)};
                        }
            }
        }
        //Normal Search
        //TODO: enable more search fields
        else {
            if ((lastName == null || lastName.trim().length() == 0) && (email == null || email.trim().length() == 0) && (phone == null || phone.trim().length() == 0)) {
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Last Name, Email, Phone, or File Number must be entered in search criteria'));
                return null;
            }
            
            
            performInvestorSearch();
            investorSearchPerformed = true;
        }
        
        
        
        return null;
    }
    
    /*

Method to take a list of Cases and convert them to a list of FileWrappers.

*/
    private List<FileWrapper> wrapFiles(List<Case> sources) {
        List<FileWrapper> results = new List<FileWrapper>();
        
        //Determine all the CaseSubjectAssociations
        Map<Id,Subject__c> subjectMap = new Map<Id,Subject__c>();
        for (Case file: sources) {
            if (file.CaseSubjectAssociations__r != null) {
                for (CaseSubjectAssociation__c assoc: file.CaseSubjectAssociations__r) {
                    subjectMap.put(assoc.subject__c,null);
                }
            }
            
        }//This bracket was moved above this if statement because the query should be outside the for loop.
        if (subjectMap != null && subjectMap.size() > 0) {
            subjectMap = new Map<Id,Subject__c>([Select Id, Name from Subject__c where Id in :subjectMap.keySet()]);
        }
        
        
        
        for (Case file: sources) {
            List<Subject__c> subjects = null;
            if (subjectMap != null && file.CaseSubjectAssociations__r != null) {
                subjects = new List<Subject__c>();
                for (CaseSubjectAssociation__c assoc: file.CaseSubjectAssociations__r) {
                    Id subjectId = assoc.subject__c;
                    Subject__c subject = subjectMap.get(subjectId);
                    if (subject != null) {
                        subjects.add(subject);
                    }
                }
            }
            
            results.add(new FileWrapper(file,subjects));
        }
        
        return results;
    }
    
    
    /*

File Search action available from 'Find Files' button on Search page.

*/
    public PageReference searchFiles() {
        Id accountId = System.currentPageReference().getParameters().get('accountId');
        Id contactId = System.currentPageReference().getParameters().get('contactId');
        //TODO: handle existing cases with SuppliedEmail matching
        system.debug('** Account ID ** '+accountID);
        rowFlag(accountId);
        
        files = null;
        files2 = null;
        
        List<Case> results = [Select Id, Origin, Owner.Name, CreatedDate, CaseNumber, Description, Subject, Status, Account.Id, Account.Name, Account.PersonContactId,Account.Full_Correspondent_Name__pc,
                              Account.Primary_Email__pc, Account.Personal_Email__pc, Account.Other_Email__pc, Account.PersonHomePhone, Account.PersonOtherPhone, Account.PersonAssistantPhone,
                              Account.Correspondent_Type__pc, Account.personmailingstate, Account.ACTS_Flag__pc, (Select Id, Subject__c from CaseSubjectAssociations__r) from Case where AccountId = :AccountId and Id != :file.id LIMIT 100];
        
        //This snippet checks to see how large the query size was and if it's over 100 display a message to users.
        integer cnt = [select count() from Case where AccountId = :AccountId and Id != :file.id];
        if(cnt!=null&&cnt>100){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'The list of results is over 100 records.  Only the first 100 records are displayed.'));
        }
        //*********************************************************************************
        
        if (results != null && results.size() == 0) {
            files = null;
        }
        else {
            files = wrapFiles(results);
        }
        
        //Added to allow the return of Correspondent Role files instead of just Correspondent related files
        Set <ID> roleIDs = new set <ID>();
        for(CaseContactRole c :[select CasesId from CaseContactRole where ContactId =:contactId]){
            roleIDs.add(c.CasesId);
        }
        
        List<Case> results2 = [Select Id, Origin, Owner.Name, CreatedDate, CaseNumber, Description, Subject, Status, Account.Id, Account.Name, Account.PersonContactId,Account.Full_Correspondent_Name__pc,
                               Account.Primary_Email__pc, Account.Personal_Email__pc, Account.Other_Email__pc, Account.PersonHomePhone, Account.PersonOtherPhone, Account.PersonAssistantPhone,
                               Account.Correspondent_Type__pc, Account.personmailingstate, Account.ACTS_Flag__pc, (Select Id, Subject__c from CaseSubjectAssociations__r) from Case where Id IN :roleIDs LIMIT 100];
        
        //This snippet checks to see how large the query size was and if it's over 100 display a message to users.
        integer cnt2 = [select count() from Case where Id IN :roleIDs];
        if(cnt2!=null&&cnt2>100){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'The chosen Correspondent is a Correspondent Role on more than 100 files.  Only the first 100 records are displayed.'));
        }
        //*********************************************************************************
        
        if (results2 != null && results2.size() == 0) {
            files2 = null;
        }
        else {
            files2 = wrapFiles(results2);
        }
        
        fileSearchPerformed = true;
        return null;
    }
    
    public void rowFlag(ID accountId){
        System.debug('**** investors **** '+investors);
        if(investors != null && investors.size() >0)
        {
            for(CorrespondentWrapper cw : investors){
                if(cw.accountId==accountId){
                    cw.rowSearchDone=true;
                }
            }
        }
    }
    
    
    /*

Overriden cancel button. Only visible when Create Correspondent section is visible.
Toggles view back to normal search page

*/
    public PageReference cancel() {
        correspondentView = false;
        return null;
    }
    
    
    /*

Used when Create Correspondent view is visible to save a new Correspondent


*/
    public PageReference save() {
        if (correspondentView) {
            
            //TODO: add Tasks for WebForms
            
            account.LastName = lastName;
            account.FirstName = firstName;
            account.Salutation = salutation;
            //Acumen 1/13/2012 Suffix not saving when correspondents are created
            account.Suffix__pc = Suffix;
            account.Correspondent_Type__pc = correspondentType;
            Database.SaveResult result = Database.Insert(account,false);
            if (result.isSuccess()) {
                account = [Select PersonContactId, Id from Account where id = :account.Id];
                if (!searchOnly) {
                    assignCaseToInvestor(account.PersonContactId,account.Id);
                }
                
                PageReference contactPage = new ApexPages.StandardController(account).view();
                contactPage.setRedirect(true);
                return contactPage;
            }
            else {
                Database.Error[] errors = result.getErrors();
                if (errors != null && errors.size() > 0 ) {
                    for (Database.Error error: errors)  {
                        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,error.getMessage()));
                    }
                }
                
            }
        }
        
        return null;
    }
    
    
    /*

Clear button used to clear the search fields

*/
    public PageReference clear() {
        firstName = null;
        lastName = null;
        email = null;
        phone = null;
        filenumber = null;
        investorSearchPerformed = false;
        fileSearchPerformed = false;
        
        return null;
    }
    
    /*

Action method used to assign a case to an existing correspondent

*/
    public PageReference assignToInvestor() {
        
        //TODO: add Tasks for WebForms
        Id accountId = System.currentPageReference().getParameters().get('accountId');
        Id contactId = System.currentPageReference().getParameters().get('contactId');
        
        if (contactId == null || accountId == null) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'No correspondent specified'));
            return null;
        }
        
        String queueStr = (String) file.ownerId;
        //Make sure this runs only when the owner is not a Group
        if (queueStr.startsWith('00G')) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'This item is current owned by a queue.  Please change the owner to an individual user and try again.'));
            return null;
        }
        //Prevent users from trying to assign files that are in an approval process.
        if(file.Status=='Awaiting Policy Review'||file.Status=='Awaiting Branch Chief Review'){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'The file you are trying to establish is currently in an approval process.  Please recall it and try to establish it again.'));
            return null;
            
        }
        
        assignCaseToInvestor(contactId,accountId);
        
        PageReference filePage = new ApexPages.StandardController(file).view();
        filePage.setRedirect(true);
        return filePage;
    }
    
    
    /*

Method used to assign this Case to this a Correspondent.


*/
    private void assignCaseToInvestor(String contactId,String accountId) {
        system.debug('assignCaseToInvestor');
        file.RecordTypeId = RecordTypes.getShortId(RecordTypes.CASE_RECORD_TYPE_FILE);
        file.ContactId = contactId;
        file.AccountId = accountId;
        file.PreProcessing__c = 'Completed';
        system.debug('File Status '+file.Status);
        system.debug('AWD '+file.AWD__c);
        if (file.Status == 'Received') {
            if(file.AWD__c!=true)
                file.Status = 'Open';
        }
        
        update file;
        
       /*** code commented Nathan to remove Activtity when addede correspondent 
        if(file.Origin == 'Web'){
            Task t = new Task(WhatId = file.Id, Subject = 'Web Form - ' + file.Web_Form_Contact_First_Name__c + ' ' + file.Web_Form_Contact_Last_Name__c, ActivityDate = system.today(), Priority = 'Normal', Status = 'Completed', Description = file.Description);
            insert t;
            
        } */
        
        
                
        //commented out to test if emtu is actually being ran
        List<Task> tasks = [Select id, WhatId from Task where whatId = : file.Id];
        List<EmailMessage> messages =  [select Id, ParentId, HasAttachment, ActivityId, TextBody, HtmlBody, Headers, Subject, FromName, FromAddress, ToAddress, CcAddress, BccAddress, Incoming,Status, MessageDate from EmailMessage where parentId = :file.Id ];
        system.debug('EmailMessageTaskUtilBatch assignCaseToInvestor');
        emtu = new EmailMessageTaskUtilBatch(messages,Tasks,Userinfo.getUserId(),file.Id,true);
        
        /*****old code
Set<Id> attachmentList = emtu.emailMessagesWithAttachments;
if (attachmentList == null) {
attachmentList = new Set<Id>();
}
attachmentList.add(file.Id);

List<Attachment> oldAttachments = [Select Id, Name, ParentId,ContentType, Body from Attachment where parentId in :attachmentList];
if (oldAttachments != null && oldAttachments.size() >= 1) {
List<Attachment> attachments = new List<Attachment>();
for (Attachment oldAttachment : oldAttachments) {
Attachment attachment = new Attachment();
attachment.ContentType = oldAttachment.ContentType;
attachment.name = oldAttachment.Name;
attachment.Body = oldAttachment.Body;
attachment.ParentId = file.Id;
attachments.add(attachment);
}

insert attachments;
}
*/
        
        //commented out to test if emtu is actually being ran
        //emtu.commitChanges();
        if (emtu.oldAttachmentsId != null && emtu.oldAttachmentsId.size() > 0) {
            Database.executeBatch(emtu, 1);
        }
    }
    
    
    //Create Correspendent
    public PageReference createCorrespondent() {
        
        // Delimiter Code Correspondent Business Logic for Phone Parse AM-02/19/2014 END 
        
        String valuestr = (String)phone;
        
        if(valueStr!=null && valueStr.contains('*')){
            valueStr=valueStr.replace('*', '');
        }
        
        if(valueStr!=null && valueStr.contains('-')){
            valueStr=valueStr.replace('-', '');
        }
        
        if(valueStr!=null && valueStr.contains('&')){
            valueStr=valueStr.replace('&', '');
        }
        
        if(valueStr!=null && valueStr.contains('$')){
            valueStr=valueStr.replace('$', '');
        }
        
        if(valueStr!=null && valueStr.contains('#')){
            valueStr=valueStr.replace('#', '');
        }
        
        if(valueStr!=null && valueStr.contains('@')){
            valueStr=valueStr.replace('@', '');
        }
        
        if(valueStr!=null && valueStr.contains('!')){
            valueStr=valueStr.replace('!', '');
        }
        
        if(valueStr!=null && valueStr.contains('?')){
            valueStr=valueStr.replace('?', '');
        }
        
        if(valueStr!=null && valueStr.contains('/')){
            valueStr=valueStr.replace('/', '');
        }
        
        if(valueStr!=null && valueStr.contains(';')){
            valueStr=valueStr.replace(';', '');
        }
        
        if(valueStr!=null && valueStr.contains('.')){
            valueStr=valueStr.replace('.', '');
        }
        
        if(valueStr!=null && valueStr.contains(',')){
            valueStr=valueStr.replace(',', '');
        }
        
        if(valueStr!=null && valueStr.contains(':')){
            valueStr=valueStr.replace(':', '');
        }
        
        if(valueStr!=null && valueStr.contains('(')){
            valueStr=valueStr.replace('(', '');
        }
        
        if(valueStr!=null && valueStr.contains(')')){
            valueStr=valueStr.replace(')', '');
        }
        
        if(valueStr!=null && valueStr.contains(' ')){
            valueStr=valueStr.replace(' ', '');
        }
        
        if(valueStr!=null && valueStr.contains('%')){
            valueStr=valueStr.replace('%', '');
        }
        phone = valuestr;
        
        //Delimiter Code Correspondent Phone Parse AM-02/19/2014 END    
        
        correspondentView = true;
        if(!searchonly){
            Case tempC = [select Id, Web_Form_Contact_Street_Address__c, Web_Form_Contact_City__c,
                          Web_Form_Contact_State_Province__c, Web_Form_Contact_Zip_Postal_code__c,
                          Web_Form_Contact_Street_Address_Cont__c, Web_Form_Contact_Country__c,
                          Web_Form_Daytime_Phone__c, Web_Form_Alternate_Phone__c, SuppliedEmail from Case where Id = :file.Id];
            
            string webstreet = (tempC.Web_Form_Contact_Street_Address__c==null)?'':tempC.Web_Form_Contact_Street_Address__c;
            string webstreet2 = (tempC.Web_Form_Contact_Street_Address_Cont__c==null)?'':tempC.Web_Form_Contact_Street_Address_Cont__c;
            string webcity = (tempC.Web_Form_Contact_City__c==null)?'':tempC.Web_Form_Contact_City__c;
            string webstate = (tempC.Web_Form_Contact_State_Province__c==null)?'':tempC.Web_Form_Contact_State_Province__c;
            string webzip = (tempC.Web_Form_Contact_Zip_Postal_code__c==null)?'':tempC.Web_Form_Contact_Zip_Postal_code__c;
            string webcountry = (tempC.Web_Form_Contact_Country__c==null)?'':tempC.Web_Form_Contact_Country__c;
            string webphone = (tempC.Web_Form_Daytime_Phone__c!=null&&phone=='')?tempC.Web_Form_Daytime_Phone__c:(phone!=null&&phone.length()==10)?'(' + phone.substring(0,3) + ') ' + phone.substring(3,6) + '-' + phone.substring(6,10):phone;
            //Alternate Phone # Update AM-9_23_2014
            string webAltPhone = (tempC.Web_Form_Alternate_Phone__c==null)?'':tempC.Web_Form_Alternate_Phone__c;
            account = new Account(Primary_Email__pc = email,
                                  Phone = webphone,
                                  recordTypeId = RecordTypes.ACCOUNT_RECORD_TYPE_CORRESPONDENT,
                                  PersonMailingStreet = webstreet +'\n'+ webstreet2,
                                  PersonMailingCity = webcity,
                                  PersonMailingState = webstate,
                                  PersonMailingPostalCode = webzip,
                                  PersonMailingCountry = webcountry,
                                  PersonOtherPhone = webAltPhone);
        }
        else{
            account = new Account(Primary_Email__pc = email,
                                  Phone = (phone!=null&&phone.length()==10)?'(' + phone.substring(0,3) + ') ' + phone.substring(3,6) + '-' + phone.substring(6,10):phone,
                                  recordTypeId = RecordTypes.ACCOUNT_RECORD_TYPE_CORRESPONDENT);
            system.debug(account.recordTypeId);
        }
        
        return null;
    }
    
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','-None-'));
        options.add(new SelectOption('Mr.','Mr.'));
        options.add(new SelectOption('Ms.','Ms.'));
        options.add(new SelectOption('Mrs.','Mrs.'));
        options.add(new SelectOption('Dr.','Dr.'));
        options.add(new SelectOption('Prof.','Prof.'));
        options.add(new SelectOption('Rev.','Rev.'));
        options.add(new SelectOption('The Honorable','The Honorable'));
        return options;
    }
    
    public List<SelectOption> getSuffixType() {
        List<SelectOption> suffixOptions = new List<SelectOption>();
        Schema.DescribeFieldResult suffixResult = Contact.Suffix__c.getDescribe();
        List<Schema.PicklistEntry> suffixPL = suffixResult.getPicklistValues();
        suffixOptions.add(new SelectOption('', '-None-'));
        for(Schema.PicklistEntry f : suffixPL) {
            suffixOptions.add(new SelectOption(f.getLabel(), f.getValue()));
        }
        return suffixOptions;
    }
    
    public List<SelectOption> getCorrType() {
        List<SelectOption> corrTypeOptions = new List<SelectOption>();
        Schema.DescribeFieldResult corrTypeResult = Contact.Correspondent_Type__c.getDescribe();
        List<Schema.PicklistEntry> corrTypePL = CorrTypeResult.getPicklistValues();
        for(Schema.PicklistEntry f : corrTypePL) {
            corrTypeOptions.add(new SelectOption(f.getLabel(), f.getValue()));
        }
        return corrTypeOptions;
    }
    
    //Move the activities & attachments to the file
    public PageReference assignToFile() {
        PageReference p = null;
        Boolean queueowned = false;
        
        Id relatedFileId = System.currentPageReference().getParameters().get('relatedFileId');
        
        System.debug('*** relatedFileId: ' + relatedFileId);
        
        if (relatedFileId == null) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'No file specified'));
            return null;
        }
        
        Case c = [select ownerID from Case where ID =:relatedFileId];
        String relatedowner = (String) c.OwnerId;
        if (relatedowner.startsWith('00G')) {
            queueowned = true;
        }
        
        String queueStr = (String) file.ownerId;
        //Make sure this runs only when the owner is not a Group
        if (queueStr.startsWith('00G')) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'This item is current owned by a queue.  Please change the owner to an individual user and try again.'));
            return null;
        }
        //Added for Phase II to attach a webfile as a pdf attachment to an existing file.
        if(webFile){
            string taskstatus = queueowned?'Completed':'Not Started';
            string taskownerId = queueowned?file.ownerId:relatedowner;
            string description ='';
            Task t = new Task(WhatId = relatedFileId, Subject = 'Web Form - ' + file.Web_Form_Contact_First_Name__c + ' ' + file.Web_Form_Contact_Last_Name__c, ActivityDate = system.today(), Priority = 'Normal', Status = taskstatus, OwnerId = taskownerId, Description = file.Description);
            insert t;
            if(file.Description!=null&&file.Description.length()>4000){
                description = file.Description.substring(0,4000);
            }
            else{
                description = file.Description;
            }
            createcomment(relatedFileId, description);
            //Case casenum = [select CaseNumber from Case where Id = :file.Id];
            String pdfname = 'Webform - '+file.Web_Form_Contact_First_Name__c + ' ' + file.Web_Form_Contact_Last_Name__c;
            p = page.WebfilePDF;
            PDFAttachment pdf = new PDFAttachment(file.Id, p, relatedFileId, pdfname);
            
            List<Case> fileExists=[Select ID From Case Where ID=:file.ID];
            if(!fileExists.isEmpty())
                delete file;
            
            p = new Pagereference('/'+relatedFileId);
            return p;
        }
        else{
            
            
            integer fileCount= [Select count() from Case where Id = :file.Id];
            if(fileCount==1){
                Case file = [Select Id, OwnerId, (Select Id, WhatId from Tasks) from Case where Id = :file.Id];
                //Task should be assigned to the owner of the file
                String ownerId = file.ownerId;
                
                
                //Make sure ownerId is not a group owner
                if (ownerId != null && ownerId.startsWith('00G')) {
                    ownerId = null;
                }
                
                
                List<Task> tasks = file.Tasks;
                
                //Find all the EmailMessages with missing Tasks
                
                List<EmailMessage> oldMessages =  [select Id, ParentId, HasAttachment, ActivityId, TextBody, HtmlBody, Headers, Subject, FromName, FromAddress, ToAddress, CcAddress, BccAddress, Incoming,Status, MessageDate from EmailMessage where parentId = :file.Id ];
                system.debug('EmailMessageTaskUtilBatch assignToFile');
                emtu = new EmailMessageTaskUtilBatch(oldMessages,tasks,ownerId,relatedFileId,queueowned);
                
                               
                //emtu.commitChanges();
                if (emtu.oldAttachmentsId != null && emtu.oldAttachmentsId.size() > 0) {
                    emtu.deleteCaseId = file.Id;
                    Database.executeBatch(emtu, 1);
                } else {
                    delete file;
                }
                
                //delete file;
                
                p = new PageReference('/'+relatedFileId);
                return p;
            }
            else{
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'The File has already been processed. Please click Next on the Files tab for your next File.'));
                return null;
            }
        }
    }
    
    @future public static void createcomment(String relatedID, String description){
        CaseComment cc = new CaseComment(ParentId = relatedID, CommentBody = description);
        try{
            insert cc;
        }
        catch(exception e){
            system.debug('****** - Error inserting Case Comment '+e);
        }
        
    }
    
    public boolean getInvestorView() {
        return (investors != null) && (!correspondentView);
    }
    
    public boolean getFileView() {
        return (files != null) && (!correspondentView);
    }
    
    public boolean getFileView2() {
        return (files2 != null) && (!correspondentView);
    }
    
    //Log Misc call
    public PageReference logMiscCall() {
        Task tsk = new Task(Priority = 'Low', CallType = 'Inbound', Status = 'Completed', Subject = Label.MiscCall, ActivityDate = system.today());
        Database.SaveResult result = Database.insert(tsk,false);
        
        if (!result.isSuccess()) {
            Database.Error[] errors = result.getErrors();
            if (errors != null && errors.size() > 0 ) {
                for (Database.Error error: errors)  {
                    Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,error.getMessage()));
                }
            }
            return null;
        }
        
        //  return (new ApexPages.StandardController(tsk).view());
        return null;
    }
    
    public PageReference viewFile() {
        
        Id relatedFileId = System.currentPageReference().getParameters().get('relatedFileId');
        
        if (relatedFileId == null) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'No file specified'));
            return null;
        }
        
        return (new ApexPages.StandardController(new Case(Id = relatedFileId)).view());
    }
    
    public PageReference viewCorrespondent() {
        
        Id accountId = System.currentPageReference().getParameters().get('accountId');
        
        if (accountId == null) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'No Correspondent specified'));
            return null;
        }
        
        return (new ApexPages.StandardController(new Account(Id = accountId)).view());
    }
    
    
    /*

Used by the File Search page to redirect to new Case page

*/
    public PageReference newFile() {
        
        Id accountId = System.currentPageReference().getParameters().get('accountId');
        Id contactId = System.currentPageReference().getParameters().get('contactId');
        if (accountId == null || contactId == null) {
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'No Correspondent specified'));
            return null;
        }
        
        if(UserInfo.getUiThemeDisplayed() == 'Theme3')
          {
        //classic code
        //pagereference p = new pagereference('/500/e?retURL=%2Fapex%2FSearch&def_account_id='+accountID+'&def_contact_id='+contactID+'&RecordType=01230000000JaJr&cas7=Open&cancelURL=%2Fapex%2FileSearch&ent=Case');
        pagereference p = new pagereference('/500/e');
        p.getParameters().put('retURL','/apex/Search');
        p.getParameters().put('def_account_id',accountID);
        p.getParameters().put('def_contact_id',contactID);
        p.getParameters().put('RecordType','01230000000JaJr');
        p.getParameters().put('cas7','Open');
        p.getParameters().put('ent','Case');
        return p;
        }
      
//****Added the code for Lightning Upgrade by Nathen
    else if(UserInfo.getUiThemeDisplayed() == 'Theme4d')
    {
    String returl='/lightning/o/Case/new?defaultFieldValues=RecordType=01230000000JaJr,Status=Open,ContactId='+contactID+'';
 //  pagereference p = new pagereference('/lightning/o/Case/new?defaultFieldValues=def_account_id='+accountID+'&def_contact_id='+contactID+'&RecordType=01230000000JaJr&cas7=Open&cancelURL=%2Fapex%2FileSearch&ent=Case');
     pagereference p = new pagereference(returl);
 return p;
      }
       return null;
           }
      
 }
