/**
 * @Company     : Testing Systems.
 * @Description :
 * ****************************************************************************************
 * This class supports API operations in /createOrders/*. The methods currently supported are:
 *
 * 1. POST createOrdersFromPayload: This operation creates a new Account, Contact and Opportunity 
 * from the external payload.
 *
 * ****************************************************************************************
 * @History     :  Created on Nov 4, 2017 by Amit Tamse //Mostly the GIT path
 */
@RestResource(urlMapping='/createOrders/*')
global class OrderProcessingWebService {
    
    private static OrderProcessingConstant orderConstants = new OrderProcessingConstant();
    
    /**
     * @Desc: This class is used contain the REST request for the service
     * (payloadSize, payloadId, operationType, orderList)
     * and will be serialized before being returned
     * to the service method.
     */
    global class OrderRequestCls{
        global String payloadSize {get; set;}
        global String payLoadId {get; set;}
        global String operationType {get; set;}
        global List<OderLineItem> orderList {get; set;}
            
        global OrderRequestCls(){}
    }
    
    /**
     * @Desc: This class is used contain the REST response for the service
     * and will be serialized before being returned
     * to the service method.
     */
    global class OrderResponseCls{
		global String payLoadId {get; set;}
        global String message {get; set;}
        
        global OrderResponseCls(){}
    }
   
   /**
     * @Desc: This class is used contain the REST request for the service
     * and will be serialized before being returned
     * to the service method.
	 */
    global class OderLineItem{ 
        global String oFirstName {get; set;}
        global String oLastName {get; set;}
        global String oEmail {get; set;}
        global String oPhone {get; set;}
        global String oCurrencyCode {get; set;}
        global String oStreet {get; set;}
        global String oCity {get; set;}
        global String oState {get; set;}
        global String oCountryCode {get; set;}
        global String oZip {get; set;}
        global String oStage {get; set;}
        
        global OderLineItem(){}
    }
    
    /**
     * @Desc: This class is used contain the REST
     * response for any failures that occur as part of the
     * services and will be serialized before being
     * returned to the service method.
     */
    global class ErrorResponse {
        global ErrorResponse() { }

        global String message { get; set; }
        global String errorCode { get; set; }
    }
    
    /**
     * @Desc: This method is responsible for determining the operation
     * requested through POST and the processing logic.
     * If no supported payload is found, an error is thrown.
     */
    @HttpPost
    global static void createOrdersFromPayload(){
         // Get request / response from RestContext
        RestRequest request = RestContext.request;
        RestResponse response = Restcontext.response;
        
        System.debug(LoggingLevel.INFO, 'Request -->'+ request);
        OrderRequestCls orderRequest;
        Savepoint svpt = Database.setSavepoint();
        
        try{
            
            //It can be done in two ways - JSON.deserializeUntyped and JSON.deserialize
            //Map<String, Object> rawData = (Map<String, Object>) JSON.deserializeUntyped(request.requestBody.toString());
            System.debug(LoggingLevel.INFO, 'Request body'+ request.requestBody.toString());
            
            //Deserialize the payload from the input - Standard method to avoid errors
            if(request.requestBody.toString() != ''){
                orderRequest = (OrderRequestCls)JSON.deserialize(request.requestBody.toString(), OrderRequestCls.class);
                System.debug(LoggingLevel.INFO, 'orderRequest' + orderRequest);
            } else {
                // If no operation is passed to the service for handling, respond back with an error
                ErrorResponse errorResponse = new ErrorResponse();
                errorResponse.message = 'No supported resource found.'; 
                errorResponse.errorCode = 'NO_PAYLOAD'; 
    
                // Serialize custom response type to JSON
                String errorResonseBody = JSON.serialize(errorResponse);
    
                // Set the response body and status code
                response.statusCode = 400;
                response.headers.put('Content-Type', 'application/json');
                response.responseBody = blob.valueOf(errorResonseBody);
                return;
            }
            
            
            //Creation of a new orders - We need to check to avoid duplicacy of the data
            if(orderRequest != null && orderRequest.operationType == orderConstants.CREATE_NEW_ORDERS){
                List<OderLineItem> orderList = orderRequest.orderList;
                List<Account> accList = new List<Account>();
                Map<String, Contact> emailContactMap = new Map<String, Contact>();
                Map<String, Opportunity> emailOpportunityMap = new Map<String, Opportunity>();
                
                for(OderLineItem orderLineItem: orderList){
                    //Initiate
                    Account acct = new Account();
                    Contact cont = new Contact();
                    Opportunity opty = new Opportunity();
                    
                    //Account 
                    acct.Name = orderLineItem.oFirstName +' '+ orderLineItem.oLastName; //Normally this should be customer organization name
                    acct.Email__c = orderLineItem.oEmail;
                    acct.Phone = orderLineItem.oPhone;
                    acct.CurrencyISOCode__c = orderLineItem.oCountryCode; 
                    acct.BillingStreet = orderLineItem.oStreet;
                    acct.BillingCity = orderLineItem.oCity;
                    acct.BillingState = orderLineItem.oState;
                    acct.BillingCountry = orderLineItem.oCountryCode;
                    acct.BillingPostalCode = orderLineItem.oZip;
                    accList.add(acct);
                    
                    //Contact
                    cont.FirstName = orderLineItem.oFirstName;
                    cont.LastName = orderLineItem.oLastName;
                    cont.Email = orderLineItem.oEmail;
                    cont.Phone = orderLineItem.oPhone;
                    cont.CurrencyISOCode__c = orderLineItem.oCountryCode; 
                    //cont.AccountId = acct.Id;
                    emailContactMap.put(orderLineItem.oEmail, cont);
                        
                    //Opportunity 
                    opty.Name = 'Opportunity-' + orderLineItem.oFirstName + ' ' + orderLineItem.oLastName;
                    opty.CurrencyISOCode__c = orderLineItem.oCountryCode;
                    opty.StageName = orderLineItem.oStage;
                    //opty.AccountId = acct.Id;
                    
                    opty.CloseDate = Date.today().addYears(1); //ToDo: Closing Date should be decided for the opportunity.
                    emailOpportunityMap.put(orderLineItem.oEmail, opty);
            	}
                //Upsert based on the email as unique identifier
                upsert accList Email__c;
                
                List<Contact> contactList = new List<Contact>();
                List<Opportunity> opptyList = new List<Opportunity>();
                
                for(Account acnt: accList){
                    //Get the respective Contact
                    Contact cnt = emailContactMap.get(acnt.Email__c);
                    cnt.AccountId = acnt.Id;
                    //Get the respective Opportunity
                    Opportunity opty = emailOpportunityMap.get(acnt.Email__c);
                    opty.AccountId = acnt.Id;
                    
                    //Add the values to the list to update at the last
                    contactList.add(cnt);
                    opptyList.add(opty);
                }
                upsert contactList;
                upsert opptyList;
                
                //Add response 
                OrderResponseCls orderResponse = new OrderResponseCls();
                orderResponse.payLoadId = orderRequest.payLoadId;
                orderResponse.message = 'sucess';
                
                //Serialize the custom response type to JSON
                String responseBody = JSON.serialize(orderResponse);
                
                //Response body 
                response.statusCode = 200;
                response.headers.put('Content-Type', 'application/json');
            	response.responseBody = blob.valueOf(responseBody);
            }else{
                //Other operations
            }
            
        }catch(Exception ex){
            
            System.debug(LoggingLevel.INFO, ex.getMessage());

            // Roll-back the creation of orders if something fails in between the transaction.
            Database.rollback(svpt);
            
            // If there is any failure during the transaction
            ErrorResponse errorResponse = new ErrorResponse();
            errorResponse.errorCode = 'Bad_Request';
            errorResponse.message = 'Error creating Account, Contact and Opportunities :' + ex.getMessage();
            errorResponse.message += ' Stack Trace: ' + ex.getStackTraceString();

            // Serialize custom response type to JSON
            String errorResonseBody = JSON.serialize(errorResponse);

            // Set the response body and status code
            response.statusCode = 500;
            response.headers.put('Content-Type', 'application/json');
            response.responseBody = blob.valueOf(errorResonseBody);
            return;
        }
    }
}
