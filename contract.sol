contract Ballot {
    
    enum States { Open, Closed }
    
    string database;
    
    States votingState;
    
    struct Voter {
        string name;
        bool voted;
        bool exists;
    }
    string [] stateString;
    struct Candidate{
        Voter voterInfo;
        bool isCandidate;
        uint8 votes;
    }
    
    uint numberOfVoters;
    address private chairperson;
    mapping(address => Voter) voters;
    mapping(uint => Candidate) candidates;
    event newVote(string candidateName, uint votes);
    event dictatorEvnt(string msg);
    
    constructor() public {
        chairperson = msg.sender;
    }
    
    function registerVoter(string memory _name) public {
        voters[msg.sender] = Voter({
            name: _name,
            voted: false,
            exists: true
        });
        numberOfVoters += 1;
    }
    
    function getNumberOfVoters() public view returns(uint){
        return(numberOfVoters);
    }
    
    function getVoterInfo(address _address) public view returns(string memory, bool){
        return(voters[_address].name, voters[_address].voted);
    }
    
    function getCandidateInfo(uint candidateNumber) public
    checkIfIsCandidateIsValid(candidateNumber)
    view returns (string memory, uint8)
    {
        return (candidates[candidateNumber].voterInfo.name, candidates[candidateNumber].votes);
    }
    
    function becomeInCandidate(uint candidateNumber) public {
        candidates[candidateNumber].voterInfo = voters[msg.sender];
        candidates[candidateNumber].isCandidate = true;
        candidates[candidateNumber].votes = 0;
    }
    
    function voteForCandidate(uint candidateNumber) public 
    electionsPeriod()
    checkIfAlreadyVoted(msg.sender)
    checkIfIsCandidateIsValid(candidateNumber)
    {
        voters[msg.sender].voted = true;
        candidates[candidateNumber].votes += 1;
        emit newVote(candidates[candidateNumber].voterInfo.name, candidates[candidateNumber].votes);
    }
    
    function setVotingStatus() public 
    isChairPerson(msg.sender)
    {
        if(votingState == States.Open) votingState = States.Closed;
    }
    
    function getVotingStatus() public returns(string memory)
    {
        if (votingState == States.Open) return("Open");
        else return("Closed");
    }
    
    function becomeDictator() public payable{
        require(msg.value > 1 ether, "Sorry. You require more ether to become Dictator.");
        chairperson = msg.sender;
        emit dictatorEvnt("You are our new Dictator!");
    }
    
    function getChairperson() public view returns(address){
        return(chairperson);
    }
    
    modifier checkIfIsCandidateIsValid(uint cNumber) {
        require(candidates[cNumber].isCandidate == true, "Sorry. There is not a candidate with that number.");
        _;
    }
    
    modifier checkIfAlreadyVoted(address _address) {
        require(voters[_address].voted == false, "Sorry. You already voted.");
        _;
    } 
    
    modifier isChairPerson(address _address){
        require(_address == chairperson, "Sorry. You are not the Chair person");
        _;
    }
    
    modifier electionsPeriod(){
        require(votingState == States.Open, "Sorry. Elections period closed.");
        _;
    }
    
}