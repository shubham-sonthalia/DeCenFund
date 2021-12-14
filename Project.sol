pragma solidity >=0.7.0 <0.9.0;
import './DecenFund.sol';

// SPDX-License-Identifier:UNLICENSED

/** @title Project Contract */
contract Project 
{   
    /*
    A struct to encapsulate the attributes of a Project 
    */
    struct Properties
    {
        uint targetAmount;
        uint deadline;
        string title;
        uint startTime;
        string emailIDOfCreator;
    }
     
     // Some state variables.
     uint public collectedAmount;
     Properties public properties;
     address public DF; 
     address payable public creator;
     
     // stores the projects as a mapping of project number with their properties
     mapping (uint => Properties) projects;
     
    event EventDonationReceived(address projectAddress, address contributor, uint amount);
    event EventPayoutInitiated(address projectAddress, address owner, uint totalPayout);
    event EventTargetedAmountReached(address projectAddress, uint totalFunding);
    event EventFundingFailed(address projectAddress, uint totalFunding);
    
    event Error(string message);
    
    /*
    modifier to only allow the owner of decenfund contract to create projects
    */
    modifier onlyDecenFund {
        if (DF != msg.sender)
        {
            emit Error("Unauthrorized access!!");
            revert("Unauthrorized access!!");
        }
        _;
    }
    
    constructor (uint _targetAmount, uint _targetInDays, string memory _title, address payable _creator, string memory _email) {

        uint deadline = block.timestamp + _targetInDays*86400;
        DF = msg.sender;
        properties = Properties({
            targetAmount: _targetAmount,
            deadline: deadline,
            title: _title,
            startTime:block.timestamp,
            emailIDOfCreator:_email
        });
        creator = _creator;
        collectedAmount = 0;
    }

    /** @dev  Transfer funds to the project & call payout incase of reaching the target amount
      * @param _donator the address of donator
      * @param _fval donation amount in wei's
      * @return successful boolean value indicating transfer status
    */   
    function fund(address _donator, uint _fval) payable onlyDecenFund external returns (bool successful) 
    {
        address payable _Donator = payable(_donator);
        if(block.timestamp > properties.deadline) 
        {
            payout();   
            emit EventFundingFailed(address(this),collectedAmount);
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
        collectedAmount += _fval;
       emit  EventDonationReceived(address(this), _donator, _fval);

        // Check again to see whether the last contribution met the fundingGoal 
        if (collectedAmount >= properties.targetAmount) {
            emit EventTargetedAmountReached(address(this), collectedAmount);
            payout();
        }
        return true;
    }

    /** @dev Transfer collected amount to beneficiary address & close the project */
    function payout() private 
    {
        uint amount = collectedAmount;
        // prevent re-entrancy
        collectedAmount = 0;
        DecenFund d = DecenFund(DF);
        d.receivePayment(creator, amount);
        bytes32 projectHash = keccak256(abi.encodePacked(properties.targetAmount, properties.deadline, properties.title, properties.emailIDOfCreator));
        d.deleteProject(projectHash);
    }

    fallback() external{
        revert('Fallback error');
    }
    
}
