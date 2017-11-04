/**
 * Company     : Testing Systems
 * Description :
 * ****************************************************************************************
 * OrderProcessingWebService unit tests
 * ****************************************************************************************
 * @History    : Created on Nov 4, 2017 by Amit Tamse //Mostly the GIT path
 */
@isTest
private class OrderProcessingWebService_Test {
   
    private static List<OrderProcessingWebService.OderLineItem> orderLineItems = new List<OrderProcessingWebService.OderLineItem>();
    //  -------------------------------------------------------------------------------------------------------------------
    //  Test Setup
    //  -------------------------------------------------------------------------------------------------------------------
   /**
    * @Desc: Creates the test data for the test session.
    */
    @testSetup private static void setupTestData(){
        
        //Line Items
        OrderProcessingWebService.OderLineItem orderLineItem = new OrderProcessingWebService.OderLineItem();
        orderLineItem.oFirstName = 'Amit';
        orderLineItem.oLastName = 'Tamse';
        orderLineItem.oEmail = 'TAMSE@testing.com';
        orderLineItem.oPhone = '777777777';
        orderLineItem.oCurrencyCode = 'USD';
        orderLineItem.oStreet = '345 Park Avenue';
        orderLineItem.oCity = 'SAN JOSE';
        orderLineItem.oCountryCode = 'US';
        orderLineItem.oZip = '95136';
        orderLineItem.oStage = 'Reserved';
        orderLineItems.add(orderLineItem);
        
        OrderProcessingWebService.OderLineItem orderLineItem1 = new OrderProcessingWebService.OderLineItem();
        orderLineItem1.oFirstName = 'Kavita';
        orderLineItem1.oLastName = 'Tamse';
        orderLineItem1.oEmail = 'KAVITA.TAMSE@testing.com';
        orderLineItem1.oPhone = '8888888888';
        orderLineItem1.oCurrencyCode = 'USD';
        orderLineItem1.oStreet = '4400 The Woods Dr';
        orderLineItem1.oCity = 'SAN JOSE';
        orderLineItem1.oCountryCode = 'US';
        orderLineItem1.oZip = '95136';
        orderLineItem1.oStage = 'Reserved';
        orderLineItems.add(orderLineItem1);
		
	OrderProcessingWebService.OderLineItem orderLineItem2 = new OrderProcessingWebService.OderLineItem();
        orderLineItem2.oFirstName = 'Kiran';
        orderLineItem2.oLastName = 'Tamse';
        orderLineItem2.oEmail = 'KIRAN.TAMSE@testing.com';
        orderLineItem2.oPhone = '9999999999';
        orderLineItem2.oCurrencyCode = 'USD';
        orderLineItem2.oStreet = '4400 The Woods Dr';
        orderLineItem2.oCity = 'SAN JOSE';
        orderLineItem2.oCountryCode = 'US';
        orderLineItem2.oZip = '95136';
        orderLineItem2.oStage = 'Reserved';
        orderLineItems.add(orderLineItem2);      
        
        OrderProcessingWebService.OderLineItem orderLineItem3 = new OrderProcessingWebService.OderLineItem();
        orderLineItem3.oFirstName = 'Kunal';
        orderLineItem3.oLastName = 'Tamse';
        orderLineItem3.oEmail = 'KUNAL.TAMSE@testing.com';
        orderLineItem3.oPhone = '787878787';
        orderLineItem3.oCurrencyCode = 'USD';
        orderLineItem3.oStreet = '4400 The Woods Dr';
        orderLineItem3.oCity = 'SAN JOSE';
        orderLineItem3.oCountryCode = 'US';
        orderLineItem3.oZip = '95136';
        orderLineItem3.oStage = 'Reserved';
        orderLineItems.add(orderLineItem3);  
        
    }
    
    //  -------------------------------------------------------------------------------------------------------------------
    //  Tests
    //  -------------------------------------------------------------------------------------------------------------------
    
    /**
    * @Desc: This method is used to test the creation of the Account, Contact and Opportunity.
    */
    @isTest public static void testCreateOrdersFromPayload(){
        Test.startTest();
            OrderProcessingWebService.OrderResponseCls agmtResponce = new OrderProcessingWebService.OrderResponseCls();
            OrderProcessingWebService.OrderRequestCls reqst = new OrderProcessingWebService.OrderRequestCls();
            reqst.payloadSize = '4';
            reqst.payLoadId = '123456789101112';
            reqst.operationType = 'ORDER_CREATE'; 
        	reqst.orderList = orderLineItems;
     		
            //Serialize the request data 
            String JsonMsg = JSON.serialize(reqst);
                   
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
     		
            req.requestURI = 'https://'+URL.getSalesforceBaseUrl().getHost()+'/services/apexrest/createOrders';  
            req.httpMethod = 'POST';
            RestContext.request = req;
            RestContext.response = res;
            req.requestBody = Blob.valueof(JsonMsg);
            OrderProcessingWebService.createOrdersFromPayload();
        Test.stopTest();
    }
}
