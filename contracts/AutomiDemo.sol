pragma solidity ^0.4.15;

//interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }

contract AutomiDemo {
    
    // =================
    // Stems stuff
    // =================
    uint256 latestStemId;
    uint256 stemEquityDecimals;
    uint256 multiplierNumerator; // Super magic numbers for now
    uint256 multiplierDenominator; // Super magic numbers for now

    // =================
    // Token stuff
    // =================
    // Public variables of the token
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    // 18 decimals is the strongly suggested default, avoid changing it
    uint256 public totalSupply;

    // This creates an array with all balances
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);

    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);
    
    // =================
    // Stems stuff
    // =================
    
    struct Stem {
        uint256 stemId;
        string title;
        string description;
        uint256 totalDistributedEquity;
        uint256 totalStakedLief;
        mapping (address => uint256) equityStakes;
    }
    
    mapping (uint256 => Stem) public stems;

    function AutomiDemo() public {
        // Lief stuff
        latestStemId = 0;
        stemEquityDecimals = 1000000;

        // Stem stuff
        totalSupply = 1000000 ** uint256(decimals); 
        balanceOf[msg.sender] = totalSupply; 
        name = "Lief";
        symbol = "LIEF";
        multiplierNumerator = 100000;
        multiplierDenominator = 100000;
    }
    
    function createStem(string stemTitle, string stemDescription) public returns (bool success) {
        latestStemId += 1;
        Stem memory newStem = Stem({
            stemId: latestStemId,
            title: stemTitle,
            description: stemDescription,
            totalDistributedEquity: 0,
            totalStakedLief: 0
        });
        stems[latestStemId] = newStem;
        multiplierNumerator = 100000; // hacky af
        multiplierDenominator = 100000; //hacky af
        return true;
    }
    
    function stakeLief(uint256 stemId, uint256 stakedLiefs) payable stemExists(stemId) public returns (bool success) {
        // transfer(this, stakedLiefs); // TODO: Commenting out first, 
        //this is not working for demo since we are using 1 account and this is sending from 1 account to same account
        balanceOf[msg.sender] -= stakedLiefs;
        _giveEquityOfStem(stemId, msg.sender, _determineEquityToGive(stemId, stakedLiefs));
        _giveLiefToStem(stemId, stakedLiefs);
        multiplierDenominator += 1000; // Ideally we should be doing this per block or something
        return true;
    }
    
    function burnEquity(uint256 stemId, uint256 burnedEquity) stemExists(stemId) public returns (uint256 liefsReturned) {
        assert(burnedEquity <= stems[stemId].equityStakes[msg.sender]);
        uint256 liefToGive = (burnedEquity / stems[stemId].totalDistributedEquity) * stems[stemId].totalStakedLief;
        stems[stemId].totalDistributedEquity -= burnedEquity;
        _withdrawLiefFromStem(stemId, msg.sender, liefToGive);
        return liefToGive;
    }
    
    function getTitleOfStem(uint256 stemId) public returns (string stemTitle) {
        return stems[stemId].title;
    }
    
    function getDescriptionOfStem(uint256 stemId) public returns (string stemDescription) {
        return stems[stemId].description;
    }
    
    function getTotalStakedLiefsOfStem(uint256 stemId) public returns (uint256 stakedLiefs) {
        return stems[stemId].totalStakedLief;
    }
    
    function getTotalDistributedEquityOfStem(uint256 stemId) public returns (uint256 distributedEquity) {
        return stems[stemId].totalDistributedEquity;
    }
    
    function getDistributedEquityOfStemOfUser(uint256 stemId, address user) public returns (uint256 stakedLiefs) {
        return stems[stemId].equityStakes[user];
    }
    
    function _determineEquityToGive(uint256 stemId, uint256 stakedLiefs) internal returns (uint256 equityToGive) {
        // using magic equity determination algorithm for now
        stemId = stemId * 1; // TODO: gotta refactor this function stemId not being used and throw off warning
        return stakedLiefs * (multiplierDenominator / multiplierNumerator);
    }
    
    function _giveEquityOfStem(uint256 stemId, address user, uint256 equityAmount) internal returns (bool success) {
        stems[stemId].equityStakes[user] += equityAmount;
        stems[stemId].totalDistributedEquity += equityAmount;
        return true;
    }
    
    function _giveLiefToStem(uint256 stemId, uint256 liefAmount) internal returns (bool success) {
        stems[stemId].totalStakedLief += liefAmount;
        return true;
    }
    
    function _withdrawLiefFromStem(uint256 stemId, address user, uint256 liefAmount) internal returns (bool success) {
        user = user; // TODO gotta refactor this function, user not used
        assert(stems[stemId].totalStakedLief - liefAmount > 0);
        stems[stemId].totalStakedLief -= liefAmount;
        return true;
    }
    
    modifier stemExists(uint256 stemId) {
        require(stems[stemId].stemId != 0);
        _;
    }
    
    // =================
    // Token stuff
    // =================
    /**
     * Internal transfer, only can be called by this contract
     */
    function _transfer(address _from, address _to, uint _value) internal {
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != 0x0);
        // Check if the sender has enough
        require(balanceOf[_from] >= _value);
        // Check for overflows
        require(balanceOf[_to] + _value > balanceOf[_to]);
        // Save this for an assertion in the future
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        // Subtract from the sender
        balanceOf[_from] -= _value;
        // Add the same to the recipient
        balanceOf[_to] += _value;
        Transfer(_from, _to, _value);
        // Asserts are used to use static analysis to find bugs in your code. They should never fail
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    /**
     * Transfer tokens
     *
     * Send `_value` tokens to `_to` from your account
     *
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }

    /**
     * Transfer tokens from other address
     *
     * Send `_value` tokens to `_to` in behalf of `_from`
     *
     * @param _from The address of the sender
     * @param _to The address of the recipient
     * @param _value the amount to send
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    /**
     * Set allowance for other address
     *
     * Allows `_spender` to spend no more than `_value` tokens in your behalf
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     */
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    /**
     * Set allowance for other address and notify
     *
     * Allows `_spender` to spend no more than `_value` tokens in your behalf, and then ping the contract about it
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     * @param _extraData some extra information to send to the approved contract
     */
    //function approveAndCall(address _spender, uint256 _value, bytes _extraData)
    //    public
    //    returns (bool success) {
    //    tokenRecipient spender = tokenRecipient(_spender);
    //    if (approve(_spender, _value)) {
    //        spender.receiveApproval(msg.sender, _value, this, _extraData);
    //        return true;
    //    }
    //}

    /**
     * Destroy tokens
     *
     * Remove `_value` tokens from the system irreversibly
     *
     * @param _value the amount of money to burn
     */
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough
        balanceOf[msg.sender] -= _value;            // Subtract from the sender
        totalSupply -= _value;                      // Updates totalSupply
        Burn(msg.sender, _value);
        return true;
    }

    /**
     * Destroy tokens from other account
     *
     * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
     *
     * @param _from the address of the sender
     * @param _value the amount of money to burn
     */
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);                // Check if the targeted balance is enough
        require(_value <= allowance[_from][msg.sender]);    // Check allowance
        balanceOf[_from] -= _value;                         // Subtract from the targeted balance
        allowance[_from][msg.sender] -= _value;             // Subtract from the sender's allowance
        totalSupply -= _value;                              // Update totalSupply
        Burn(_from, _value);
        return true;
    }
    
}