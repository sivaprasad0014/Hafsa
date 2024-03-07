/* 
  SECQueryBuilder.cls
  Contains methods for SOQL, Custom SOQL, and SOSL generation for use
  by the Response enhancement
  ------------------------------------------------------------------
   Author       Date      Description
  ------------------------------------------------------------------
  Ken Wright      3/28/2013    Created
*/
public with sharing class SECQueryBuilder {
  private SECParameters params;
  private Set<String> ids;
  private static final String APPROVED = 'Approved';
  private static final String UNAPPROVED = 'Unapproved';
  private static final String BOTH = 'Both';

  public SECQueryBuilder() {}
  
  /************************** CUSTOM SOQL METHODS ***********************/
  public String generateMergeSOQL(List<String> fields,String objectName,String id){
    String qry = '';
    qry += getCustomSelect(fields) +' ';
    qry += getCustomFrom(objectName)+' ';
    qry += getCustomWhere(id)+' ';
    qry += getCustomLimit();
    return qry;
  }

  private String getCustomSelect(List<String> fields){
    String sel = 'SELECT ';
    for(String s: fields){
      sel += ',' + s ;
    }
    sel = sel.replaceFirst(',','');
    return sel;
  }

  private String getCustomFrom(String objectName){
    return 'FROM '+ objectName;
  }

  private String getCustomWhere(String recordId){
    return 'WHERE id = \''+recordId+'\'';  
  }

  private String getCustomLimit(){
    return 'LIMIT 1';
  }
  /************************** END CUSTOM SOQL METHODS ***********************/

  /************************** SOQL METHODS ***********************/
  public String generateSOQL(SECParameters params){
    //this.ids = ids;
    this.params = params;
    String qry = '';
    qry += getSelect() +' ';
    qry += getFrom()+' ';
    qry += getSOQLWhere()+' ';
    qry += getSOQLOrderBy()+' ';
    qry += getSOQLLimit();
    return qry;
  }

  private String getSelect(){
    return 'SELECT Response_Detail__c,CreatedDate,Times_Cloned__c,Date_Approved__c,Status__c,Response_Title__c,Approved__c,CreatedBy.Name, OCC_Approved__c,Branch__c';
  }


  private String getFrom(){
    return 'FROM New_Response__c';
  }
  
  private String getSOQLWhere(){
    String qry = 'WHERE';
    
    qry += getWhereClause('Response_Title__c',params.titleSearch,'LIKE');
    qry += getWhereClause('CreatedBy.Name',params.createdBySearch,'LIKE');
    qry += getWhereClause('Approved__c',params.approval);
    
    //Parameter Code Update AM 03/10/2014 OCC Checkbox Logic
        if(params.OCCApproved != false)
        qry += getWhereClause('OCC_Approved__c',APPROVED);

    if(qry == 'WHERE'){
      return ' WHERE Status__c = \'Custom\' AND Status__c <> \'Archived\'';
    }else{
      qry = qry.replaceFirst('AND','');
      qry += ' AND Status__c = \'Custom\' AND Status__c <> \'Archived\'';
    }

    return qry;
  }

  private String getSOQLOrderBy(){
    return 'ORDER BY CreatedDate DESC';
  }

  private String getSOQLLimit(){
    return 'LIMIT 200';
  }

  private String listToString(Set<String> ids){
    return '(\''+ String.join(new List<String>(ids),'\',\'') + '\')';
  }
  /************************** END SOQL METHODS ***************/


  /************************** SOSL METHODS ****************/
  public String generateSOSL(SECParameters params){
    this.params = params;
    String qry = '';
    qry += getFind() +' ';
    qry += getFields()+' ';
    qry += getObject()+' ';
    qry += getSOSLLimit();
    system.debug('Kenny+++'+qry);
    return qry;
  }

  private String getFind(){
    //return 'FIND \'' + String.join(params.basicSearchList,' OR ') +'\'';
    return 'FIND \'' + String.escapeSingleQuotes(params.basicSearch) +'\'';
  }

  private String getFields(){
    return 'IN ALL FIELDS RETURNING';
  }

  private String getObject(){
    return 'New_Response__c('+
      +'Response_Detail__c,'
      +'Times_Cloned__c,'
      +'Date_Approved__c,'
      +'Status__c,'
      +'Response_Title__c,'
      +'Approved__c,'
      +'Branch__c,'
      +'CreatedBy.Name,'
      +'CreatedDate,'
      +'OCC_Approved__c'
      + getSOSLWhere() + ' '
      + getSOSLOrderBy()
      +')';
  }

  private String getSOSLWhere(){
    String qry = ' WHERE ';

    qry += getWhereClause('Response_Title__c',params.titleSearch,'LIKE');
    qry += getWhereClause('CreatedBy.Name',params.createdBySearch,'LIKE');
    qry += getWhereClause('Approved__c',params.approval);
    
    //Parameter Code Update AM 03/10/2014 OCC Checkbox Logic
        if(params.OCCApproved !=FALSE)
        qry += getWhereClause('OCC_Approved__c','APPROVED');

    if(qry == ' WHERE '){
      return ' WHERE Status__c = \'Custom\' AND Status__c <> \'Archived\'';
    }else{
      qry = qry.replaceFirst('AND','');
      qry += 'AND Status__c = \'Custom\' AND Status__c <> \'Archived\'';
    }

    return qry;
  }

  private String getWhereClause(String fieldname, String value, String operator){
    if(value == null || value == ''){
      return '';
    }
    if(operator == 'LIKE'){
      return 'AND'+' '+fieldname+' '+operator+' '+'\'%'+String.escapeSingleQuotes(value)+'%\' ';
    }else{
      return 'AND '+fieldname+' '+operator+' '+value+' ';
    }
  }

  private String getWhereClause(String fieldname, String value){
    if(value == null || value == BOTH){
      return '';

    }else if(value == APPROVED){
      return 'AND '+fieldname+' = true ';
    }else{
      return 'AND '+fieldname+' = false ';
    }
  }

  private String getSOSLOrderBy(){
    return 'ORDER BY CreatedDate DESC';
  }

  private String getSOSLLimit(){
    return 'LIMIT 200';
  }
  /*****************END SOSL METHODS******************/
  
}
