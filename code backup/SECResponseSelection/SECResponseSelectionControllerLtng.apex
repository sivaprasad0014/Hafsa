public class SECResponseSelectionControllerLtng 
{
    @AuraEnabled 
    public static InitResponse loadData(String fileId, String responseType)
    {
        InitResponse ir = new InitResponse();
        ir.standardResplist = [SELECT Response_Title__c, Approved__c, Times_Cloned__c, CreatedBy.Name, 
                               CreatedDate, Date_Approved__c, Status__c, Response_Detail__c, Branch__c
                               FROM New_Response__c 
                               WHERE Status__c =: responseType
                               AND Status__c <> 'Archived'
                               ORDER BY CreatedDate 
                               DESC LIMIT 1000]; 
        ir.isCustomSearch = false;
        return ir;
    }    
    public class InitResponse
    {
        @AuraEnabled public List<New_Response__c> standardResplist;
        @AuraEnabled public Boolean isCustomSearch;
    }
    @AuraEnabled
    public static FilterResponse filter(String pStr)
    {
        FilterResponse fr = new FilterResponse();
        SECParameters params = (SECParameters)JSON.deserialize(pStr, SECParameters.class);
        system.debug('params..!'+params);
        
        List<List<sObject>> soslReturnList = new List<List<sObject>>();
        SECQueryBuilder qb = new SECQueryBuilder();
        List<New_Response__c> customResplist = new List<New_Response__c>();
        
        if(params.basicSearch == ''){
            customResplist = Database.query(qb.generateSOQL(params));
        }else{
            soslReturnList = search.query(qb.generateSOSL(params));
            customResplist = (List<New_Response__c>) soslReturnList.get(0);
            system.debug('customResplist >>> '+customResplist);
        }
        fr.standardWrapResplist = getWrapperForCustomResponse(customResplist);
        system.debug('fr.standardWrapResplist >>> '+fr.standardWrapResplist);
        fr.isCustomSearch = true;
        return fr;
    }
    public static List<ResponseWrapper> getWrapperForCustomResponse(List<New_Response__c> standardResplist)
    {    
        List<ResponseWrapper> standardWrapResplist = new List<ResponseWrapper> ();
        set<id>  responseSet= new set<id> ();
        for(New_Response__c resp : standardResplist)
        {
            responseSet.add(resp.id);
        }
        List<Response_15__c> jnList = [SELECT Id, File_Number__c, File_Number__r.File_Number__c, Responses_1_5__c 
                                       FROM Response_15__c 
                                       WHERE Responses_1_5__c IN: responseSet]; 
                                       
        map<String,String> jnMap = new map<String, String>();
        map<String,string> jnObjMap = new map<String, String>();

        for(Response_15__c jnResp: jnList)
        {
            jnMap.put(jnResp.Responses_1_5__c, jnResp.File_Number__r.File_Number__c);
            jnObjMap.put(jnResp.Responses_1_5__c, jnResp.File_Number__c);    
        }

        for(New_Response__c resp : standardResplist)
        {
            standardWrapResplist.add(new ResponseWrapper(resp,jnMap.get(resp.id),jnObjMap.get(resp.id)));        
        }
        return standardWrapResplist; 
    }
    public class FilterResponse
    {
        @AuraEnabled public List<ResponseWrapper> standardWrapResplist;
        @AuraEnabled public Boolean isCustomSearch;
    }
    
    @AuraEnabled
    public static New_Response__c getResponse(string responseId){
        return [SELECT Response_Title__c,Response_Detail__c 
                FROM New_Response__c 
                WHERE id =: responseId];
    }
    @AuraEnabled
    public static list<New_Response__c> filterStandard(string responseType)
    {
        return [SELECT Id, Response_Title__c, Approved__c, Times_Cloned__c, CreatedBy.Name, CreatedDate, Date_Approved__c, Status__c, Response_Detail__c, Branch__c
                FROM New_Response__c 
                WHERE Status__c =: responseType
                ORDER BY CreatedDate DESC
                LIMIT 1000];
    }
    public class ResponseWrapper
    {        
        @AuraEnabled public New_Response__c resp;
        @AuraEnabled public String fileID;
        @AuraEnabled public String caseID;
        public ResponseWrapper(New_Response__c respNew, String fileIname, string fid) 
        {            
            resp = respNew;
            fileID = fileIname;
            caseID = fid;            
        }        
    }   
}
