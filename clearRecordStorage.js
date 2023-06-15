import { LightningElement,track,wire,api } from 'lwc';
import { subscribe} from 'lightning/empApi'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import deleteRecords from '@salesforce/apex/ClearRecordStorage.deleteRecords'
import returnsObjects from '@salesforce/apex/ClearRecordStorage.returnsObjects'

export default class ClearRecordStorage extends LightningElement {

     @track Id;
     @track firstDiv;
     @track Status;
     @track TotalJobItems;
     @track JobItemsProcessed;
     @track objectAPiName;
     @track openData=false;
     @track isModalOpen = false;
     @track isModal = false;
     openPopUp = false;
     @track  dataValue = [];

     @track payload = [];
    //  @track row1 = [];
     index = 0 ;
     @track toAddData = [];
     selectedSearchKey = null;
     searchKey = null;
     @track  selectedSObject = [];
     allObjects      = [];
     @track selectedObject  = [];
     selectRecord    = [];
     objectRecord = [];
     displayObject   = 10;
     arrayofObj = [];
     selectedObjectId
       dataRecords;
       records;
     //  Status;
   
       subscription = {};
       @api channelName = '/event/BatchEvent__e';

        connectedCallback() {
            console.log('+++connectedCallback+++');
            this.handleSubscribe();
  }
   
    handleSubscribe() {
        
        const self = this;
        const messageCallback = function (response) {
            console.log('New batch received : ', JSON.stringify(response));
            var obj = JSON.parse(JSON.stringify(response));
            console.log('obj',obj.data.payload);
            let payloadData = obj.data.payload;
            console.log('Response data list:::',payloadData);

            self.Id = payloadData.Id__c;
            console.log('id',self.Id);

            self.objectAPiName = payloadData.objectAPiName__c;
            console.log('objectAPiName',self.objectAPiName);

            self.TotalJobItems = payloadData.TotalJobItems__c;
            console.log('TotalJobItems',self.TotalJobItems);

            self.JobItemsProcessed = payloadData.JobItemsProcessed__c;
            console.log('JobItemsProcessed', self.JobItemsProcessed);
           
            self.Status = payloadData.Status__c;
            console.log('Status',self.Status);

            if(self.Status === 'Processing'){
                self.openPopUp = true ;
                console.log('yellow');
          
                self.template.querySelector('[data-id="colourChange"]').classList.add('yellow');
                console.log('process status');
              
            
            }
            else if(self.Status === 'Completed')
            {
              
                console.log('green');
                self.openPopUp = false ;
                self.template.querySelector('[data-id="colourChange"]').classList.remove('yellow');
                self.template.querySelector('[data-id="colourChange"]').classList.add('green');
                
                console.log('model');
                self.dataValue[self.index] = payloadData ; 
                self.openPopUp = false ;
                 console.log('self.dataValue--->',JSON.stringify(self.dataValue));
                 console.log('self.dataValue[self.index]',JSON.stringify(self.dataValue[self.index]));
                 self.index++;
             
            }
       
        };
        subscribe(this.channelName, -1, messageCallback)//-1 is replay id
        .then(response => {
            // Response contains the subscription information on subscribe call
           // console.log('Subscription request sent to: ', JSON.stringify(response.channel));
            this.subscription = response;
        });
       
    }

     handleClick() {
       
            this.isModalOpen = true;
            
       
        
    }
    
     @wire(returnsObjects)
    wiredObjectData({data,error}){
    if(data)
    {
        this.allObjects = data;
    }else{
         this.error = error ;
    }
    }
   
   
    handleSearch(event){
      this.searchKey = event.target.value.charAt(0).toUpperCase() + event.target.value.slice(1);
    //    this.searchKey = event.target.value; 
       console.log("+++++selectKey+++++ ", this.searchKey);
       if(!this.searchKey){
        this.openData=false;
       }
     
      
       //this.selectedObject=[];
       else{
        this.openData = true;
        this.selectRecord=[];
       
        this.allObjects.forEach(element=>{
            if(element.includes(this.searchKey))
            {
                this.selectRecord.push(element);
               // console.log('selectRecord',JSON.stringify(this.selectRecord));
            }   
            // this.objectRecord = this.selectRecord.slice(0,displayObject);

        });

       }
       
     
            
            
    }
    handleClose(){
    
        console.log('inside handleClose');
        this.isModalOpen = false;
        this.isModal  = true;
       
        console.log('selectedSObject-------->',JSON.stringify(this.selectedSObject));
        console.log('searchKey',this.searchKey);
        this.handleSubscribe();
        deleteRecords({objectName:this.selectedSObject})
   
        .then(result => {
            console.log("+++++result------> ", result);

            const evt = new ShowToastEvent({
                title: 'Started',
                message: 'Job Started Successfully',
                variant: 'Success',
                mode: 'dismissible'
            });
            this.dispatchEvent(evt);
           
           

        })
        .catch(error => {
            console.log("++++++++error++++++++ ", error);
        });
       this.selectedSObject = [] ;
       this.searchKey = null;
       this.selectRecord='';

    }

     handleSelectedObject(event) {
        console.log('event.target',event.target)
        this.selectedObjectId = event.target.value;
        console.log('selectedObjectId',this.selectedObjectId);
          if(!this.selectedSObject.includes(this.selectedObjectId)){
            this.selectedSObject.push(this.selectedObjectId)
            console.log('selectedSObject',JSON.stringify(this.selectedSObject));
       }
        
        // console.log('selectedSObject',JSON.stringify(this.selectedSObject));
    }

    handleRemoveSelectedObject(event){
            const pillIndex = event.detail.index ? event.detail.index : event.detail.name;
            
            const itempill = this.selectedSObject;
            itempill.splice(pillIndex, 1);       
            this.selectedSObject = [...itempill];
             console.log('selectedSObject-->', JSON.stringify(this.selectedSObject));
        
        
    }
    closeModal()
    {
        this.isModalOpen = false;    
        this.selectedSObject = [] ;
        this.searchKey = null;
        this.selectRecord='';
    }
}