pragma solidity >=0.7.0 < 0.9.0;

import "./Project.sol";


// SPDX-License-Identifier:UNLICENSED
contract DecenFund{
    address public owner;
    uint public numOfProjects;
    address[] public listOfBeneficiaries;
    mapping (bytes32 => Project) public projects;
    mapping(address => uint) collectedAmount;

    event EventProjectCreated(uint id, string title, Project addr, address creator);
    event DonationSent(address projectAddress, address beneficiary, uint amount);

    event Error(string message);
    event ProjectDeleted(address projectAddress);
    modifier onlyOwner {
        require(msg.sender == owner, "You don't have the rights to perform this action.");
        _;
    }
    constructor() {
        owner = msg.sender;
        numOfProjects = 0;
    }
    function createProject(string calldata _name, string calldata _age, string calldata _emailID, uint _targetAmount, uint _targetInDays, string calldata _title) external payable 
    returns (Project projectAddress, address _beneficiary) {
        
        address payable benAdd = payable(address(uint160(uint256(keccak256(abi.encodePacked(_name, _age, _emailID))))));
        listOfBeneficiaries.push(benAdd);
        if (_targetAmount <= 0) {
            emit Error("Project funding goal must be greater than 0");
            revert("Project funding goal must be greater than 0");
        }
        
        if (_targetInDays <= 0) {
            emit Error("Project deadline must be greater than the current block");
            revert("Project deadline must be greater than the current block");
        }
        
        bytes32 projectHash = keccak256(abi.encodePacked(_targetAmount, _targetInDays, _title, _emailID));
        Project p = new Project(_targetAmount, _targetInDays, _title, benAdd, _emailID);
        projects[projectHash] = p;
        emit EventProjectCreated(numOfProjects, _title, p, benAdd);
        numOfProjects++;
        return (p, benAdd);
    }
    
    function donate(address _projectAddress) external payable returns (bool successful) { 
        
        if(msg.value <= 0){
            emit Error("Donations must be greater than 0 wei");
            revert("Donations must be greater than 0 wei");
        }
        Project deployedProject = Project(_projectAddress);
        // Check that there is actually a Project contract at that address
        if (deployedProject.DF() == address(0)) {
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
    function deleteProject(bytes32 _hash) public {
        numOfProjects--;
        delete projects[_hash];
        emit ProjectDeleted(msg.sender);
    }
    function getCreatorBalance(address _beneficiaryAddress) external view returns (uint) {
        return collectedAmount[_beneficiaryAddress];
    }
    function receivePayment(address _beneficiary, uint _payment) public payable {
        collectedAmount[_beneficiary] += _payment;
    }
    function kill() public onlyOwner {
    address payable Owner = payable(owner);
        selfdestruct(Owner);
    }
    fallback() external{
        revert('Fallback error');
    }
    
}
