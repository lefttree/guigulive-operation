pragma solidity ^0.4.14;

contract Payroll {
    struct Employee {
        address id;
        uint salary;
        uint lastPayday;
    }

    uint constant payDuration = 10 seconds;
    uint totalSalary;

    address owner;
    mapping(address => Employee) public employees; //Mapping

    function Payroll() {
        owner = msg.sender;
    }

    // custom modifier
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    // modifier with parameter
    modifier employeeExist(address employeeId) {
        var employee = employees[employeeId];
        assert(employee.id != 0x0);
        _;
    }
    
     // modifier with parameter
    modifier employeeNotExist(address employeeId) {
        var employee = employees[employeeId];
        assert(employee.id == 0x0);
        _;
    }

    function _partialPaid(Employee employee) private {
        uint payment = employee.salary * (now - employee.lastPayday) / payDuration;
        employee.id.transfer(payment);
    }

    function addEmployee(address employeeId, uint salary) onlyOwner employeeNotExist(employeeId) {
        var employee = employees[employeeId];

        totalSalary += salary * 1 ether;
        employees[employeeId] = Employee(employeeId, salary, now);
    }

    function removeEmployee(address employeeId) onlyOwner employeeExist(employeeId) {
        var employee = employees[employeeId];

        _partialPaid(employee);
        totalSalary -= employee.salary;
        delete employees[employeeId];
    }

    function updateEmployee(address employeeId, uint salary) onlyOwner employeeExist(employeeId) {
        var employee = employees[employeeId];
        _partialPaid(employee);
        totalSalary -= employee.salary;
        totalSalary += salary * 1 ether; // Don't forget the unit
        employee.salary = salary;
        employee.lastPayday = now;
    }

    function addFund() payable returns (uint) {
        return this.balance;
    }

    function calculateRunway() returns (uint) {
        assert(totalSalary != 0x0);
        return this.balance / totalSalary;
    }

    function hasEnoughFund() returns (bool) {
        if (totalSalary == 0x0) {
            return true;
        }
        return calculateRunway() > 0;
    }
    
    function checkEmployee(address employeeId) returns (uint salary, uint lastPayday) { //return parameters naming
        var employee = employees[employeeId];
        //return (employee.salary, employee.lastPayday);
        // return parameters assignment
        salary = employee.salary;
        lastPayday = employee.lastPayday;
    }

    function getPaid() employeeExist(msg.sender) {
        var employee = employees[msg.sender];

        uint nextPayday = employee.lastPayday + payDuration;
        assert(nextPayday < now);

        employees[msg.sender].lastPayday = nextPayday;
        employee.id.transfer(employee.salary);
    }
    
    // new method
    function changePaymentAddress(address newAddress) employeeExist(msg.sender) employeeNotExist(newAddress) {
        var employee = employees[msg.sender];
        employees[newAddress] = Employee(newAddress, employee.salary, employee.lastPayday);
        delete employees[msg.sender];
    }
}