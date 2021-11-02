pragma solidity >=0.7.0 < 0.9.0;

import "./Project.sol";

// SPDX-License-Identifier:UNLICENSED
contract DecenFund{
    address public owner;
    uint public numOfProjects;

    mapping (uint => Project) public projects;

    event EventProjectCreated(uint id, string title, Project addr, address creator);
    event DonationSent(address projectAddress, address beneficiary, uint amount);

    event Error(string message);

    modifier onlyOwner {
        require(msg.sender == owner, "You don't have the rights to perform this action.");
        _;
    }
    
    constructor() {
        owner = msg.sender;
        numOfProjects = 0;
    }
 

    function createProject(uint _targetAmount, uint _targetInDays, string calldata _title) external payable returns (Project projectAddress) {

        if (_targetAmount <= 0) {
            emit Error("Project funding goal must be greater than 0");
            revert("Project funding goal must be greater than 0");
        }

        if (_targetInDays <= 0) {
            emit Error("Project deadline must be greater than the current block");
            revert("Project deadline must be greater than the current block");
        }

        Project p = new Project(_targetAmount, _targetInDays, _title, msg.sender);
        projects[numOfProjects] = p;
        emit EventProjectCreated(numOfProjects, _title, p, msg.sender);
        numOfProjects++;
        return p;
    }

   
    function donate(address _projectAddress) external payable returns (bool successful) { 
        
        if(msg.value <= 0){
            emit Error("Donations must be greater than 0 wei");
            revert("Donations must be greater than 0 wei");
        }
        Project deployedProject = Project(_projectAddress);
        // Check that there is actually a Project contract at that address
        if (deployedProject.DecenFund() == address(0)) {
            emit Error("Project contract not found at address");
            revert("Project contract not found at address");
        }

        // Check that fund call was successful
        if (deployedProject.fund(msg.sender, msg.value)) {
            emit DonationSent(_projectAddress, msg.sender, msg.value);
            return true;
        } else {
            emit Error("Contribution did not send successfully");
            return false;
        }
    }
    
    function getStatus(address _projectAddress, address _d) external view returns (uint, uint){
        Project p = Project(_projectAddress);
        return (p.collectedAmount(), p.donors(_d));
    }
    
    function getCreatorBalance(address _projectAddress) external view returns (uint) {
        Project p = Project(_projectAddress);
        address a = p.creator();
        return a.balance;
    }
    
    function kill() public onlyOwner {
    address payable Owner = payable(owner);
        selfdestruct(Owner);
    }
    
    fallback() external{
        revert('Fallback error');
    }
}
