pragma solidity >=0.7.0 <0.9.0;

contract Transfer
{
    
    // Receiving ether to this contract.  
    
    mapping (address => uint) balances;
    uint projectID = 0;
    enum STATE{INPROGRESS, FINISHED}
    struct Project
    {
        uint target;
        uint days;
        address beneficiary;
        uint projectId;
        STATE state;
    }
    Project[] projects;
    mapping(address => uint) noOfProjects;

    function addProject (uint _target, uint _days, address beneficiary) external
    {
        require(noOfProjects[msg.sender] <= 1);
        Project memory newProject = Project(_target, _days, beneficiary, projectID, STATE.INPROGRESS);
        projectID++;
    }
    
    function donate() external payable
    {
        balances[msg.sender] += msg.value;
    }
    
    function balanceOf() external view returns (uint) 
    {
        return address(this).balance;
    }
    
    function showAddress() external view returns(address payable)
    {
        address myaddress = address(this);
        address payable wallet = payable(myaddress);
        return wallet;
        
    }
    
    /////////////////////////////////////////////////////////////////////////////////
    // Sending ether from this contract to another contract or any other user. 
    
    function sendMoney(address payable recipient) external {
        uint sum = 0;
        
        recipient.transfer(100);
    }

}
