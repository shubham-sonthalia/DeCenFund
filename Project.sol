pragma solidity >=0.7.0 <0.9.0;

// SPDX-License-Identifier:UNLICENSED
// To do: 

// 1. Project should be able to receive payments. 
// 2. User Contract. And donors and beneficiaries could inherit from it. 
// 3. Need to make a lot of events to allow communication between frontend and backend.
// 4. 
contract Project 
{
    // A data type to store the state of the project. 
    enum STATE {INPROGRESS, FINISHED}
    // A struct that stores all the details unique to the project. 
    struct Properties
    {
        uint targetAmount;
        uint deadline;
        string title;
        uint startTime;
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
     address public DecenFund; 
     address public creator;
     
     mapping (address => uint) public donors;
     mapping (uint => Properties) projects;
     
    event EventDonationReceived(address projectAddress, address contributor, uint amount);
    event EventPayoutInitiated(address projectAddress, address owner, uint totalPayout);
    event EventTargetedAmountReached(address projectAddress, uint totalFunding);
    event EventFundingFailed(address projectAddress, uint totalFunding);
    
    event Error(string message);
    
    modifier onlyDecenFund {
        if (DecenFund != msg.sender)
        {
            emit Error("Unauthrorized access!!");
            revert("Unauthrorized access!!");
        }
        _;
    }
    
     constructor (uint _targetAmount, uint _targetInDays, string memory _title, address _creator) {

        uint deadline = block.timestamp + _targetInDays*86400;
        DecenFund = msg.sender;
        properties = Properties({
            targetAmount: _targetAmount,
            deadline: deadline,
            title: _title,
            startTime:block.timestamp
        });
        creator = _creator;
        collectedAmount = 0;
        donorsCount = 0;
        state = STATE.INPROGRESS;
        // After receiving all this information, my project is created. 
    }
    function getProject() public view returns (string memory, uint, uint, uint, uint, address, address) {
        return (properties.title,
                properties.targetAmount,
                properties.deadline,
                collectedAmount,
                donorsCount,
                DecenFund,
                address(this));
    }
    
    function fund(address _donator, uint _fval) payable onlyDecenFund external returns (bool successful) 
    {
        address payable _Donator = payable(_donator);
  
        if (block.timestamp > properties.deadline) 
        {
            emit EventFundingFailed(address(this), collectedAmount);
            
            if (!_Donator.send(_fval)) 
            {
                emit Error("Project deadline has passed, problem returning contribution");
                revert("Project deadline has passed, problem returning contribution");
            } 
            return false;
        }

        // 2. Check that funding goal has not already been met
        if (collectedAmount >= properties.targetAmount) 
        {
            emit EventTargetedAmountReached(address(this), collectedAmount);
            if (!_Donator.send(_fval)) 
            {
                emit Error("Project deadline has passed, problem returning contribution");
                revert("Project deadline has passed, problem returning contribution");
            }
            payout();
            return false;
        }

        // determine if this is a new contributor
        uint prevContributionBalance = donors[_donator];

        // Update contributor's balance
        donors[_donator] += _fval;

        collectedAmount += _fval;


        // Check if contributor is new and if so increase count
        if (prevContributionBalance == 0) {
            donorsCount++;
        }

       emit  EventDonationReceived(address(this), _donator, _fval);

        // Check again to see whether the last contribution met the fundingGoal 
        if (collectedAmount >= properties.targetAmount) {
            emit EventTargetedAmountReached(address(this), collectedAmount);
            if(!payout()){
                emit Error("Payout not called");
                revert("Payout not called");
            }
            // payout();
        }

        return true;
    }
    
    function payout() private returns (bool successful) 
    {
        uint amount = collectedAmount;

        // prevent re-entrancy
        collectedAmount = 0;
        address payable Creator = payable(creator);
        if (Creator.send(amount))
        {
            return true;
        } 
        else 
        {
            collectedAmount = amount;
            return false;
        }
    }
    fallback() external{
        revert('Fallback error');
    }
    
}
