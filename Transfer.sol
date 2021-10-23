pragma solidity >=0.7.0 <0.9.0;

contract Project 
{
    // A data type to store the state of the project. 
    enum STATE {INPROGRESS, FINISHED}
    // A struct that stores all the details unique to the project. 
    struct Properties
    {
        uint targetAmount;
        uint targetInDays;
        address creator;
        string title;
    }
    // A struct that holds vital information of a donation. 
     struct Donation 
     {
        uint amount;
        address donor;
     }
     // Some state variables.
     uint public collectedAmount;
     uint public donorsCount;
     STATE public state;
     Properties public properties;
     
     
     mapping (address => uint) donors;
     mapping (uint => Properties) projects;
     
     
     constructor (uint _targetAmount, uint _targetInDays, string memory _title) {
         
        require(_targetAmount > 0, "The target amount has to be greater than 0");
        require(_targetInDays > 0, "The deadline must be in the future");
        require(bytes(_title).length > 0 && bytes(_title).length < 20, "Please enter a valid title.");
        
        
        properties = Properties({
            targetAmount: _targetAmount,
            targetInDays: _targetInDays,
            title: _title,
            creator: msg.sender
        });
        
        collectedAmount = 0;
        donorsCount = 0;
        state = STATE.INPROGRESS;
        // After receiving all this information, my project is created. 
    }
}
contract Transaction
{
    enum STATUS{INITIATED,FAILED, COMPLETED}
    enum TYPE {Unknown, Deposit, Withdrawal}
    struct features 
    {
        address fromAccount;
        address toAccount;
        uint amount;
        TYPE typeOfTxn;
        STATUS currentStatus;
        uint timestamp;
    } 
}
