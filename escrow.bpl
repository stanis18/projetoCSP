type Ref;
type string; //declarando um tipo string
type bytes20;
type bytes32;
type uint8;
type uint32;
type uint256;
type Field G; 

type address; 
const unique zeroAddress: address;
const unique validAddress: address;

type Status;
const unique FUNDED: Status;
const unique RELEASED: Status;

type TransactionType;
const unique ETHER: TransactionType;
const unique TOKEN: TransactionType;

type Transaction = <G>[Ref, Field G] G;
const null : Transaction; //Declarando um tipo null para referencias.. 
var value : Field uint256;
var lastModified : Field uint256;
var status : Field Status;
var transactionType : Field TransactionType;
var threshold : Field uint8;
var timeoutHours : Field uint32;
var buyer : Field address;
var seller : Field address;
var tokenAddress : Field address; 
var moderator : Field address;
var released : Field uint256;
var noOfReleases : Field uint256; 
var isOwner : Field [address] bool;
var voted : Field [bytes32] bool;
var beneficiaries : Field [address] bool;

//-------------------------------------------------------------------------
//Memory

var Transactions : [bytes32] Transaction; //map para referenciar as transacoes

var PartyVsTransaction : [address] [int] bytes32; //mapa de para um array de bytes32

var transactionCount : int;


//-----------------------------Modifiers--------------------------------------------

 function transactionDoesNotExistModifier(scriptHash : bytes32) returns (bool) {
    Transactions[scriptHash] == null;
    //var transaction : Transaction;
    //transaction := Transactions[scriptHash];
    //transactionExists := transaction == null;
    }


//-------------------------------------------------------------------------


procedure addTransaction(buyer : address, seller : address, moderator : address, threshold : uint8, 
timeoutHours : uint32, scriptHash: bytes32, uniqueId : bytes20, msg.sender : address, msg.value : uint256 ) 
requires transactionDoesNotExistModifier(scriptHash); {

    call addTransaction_ (buyer, seller, moderator, threshold, timeoutHours, scriptHash, msg.value, 
    uniqueId, ETHER, zeroAddress, msg.sender);
}

procedure addTokenTransaction(buyer : address, seller : address, moderator : address, threshold : uint8, 
timeoutHours : uint32, scriptHash: bytes32, value : uint256, uniqueId : bytes20, msg.sender : address ) {

    call addTransaction_ (buyer, seller, moderator, threshold, timeoutHours, scriptHash, value, 
    uniqueId, TOKEN, zeroAddress, msg.sender);
}

procedure addTransaction_ (buyer : address, seller : address, moderator : address, threshold : uint8,
timeoutHours : uint32, scriptHash : bytes32, value : uint256, uniqueId : bytes20, 
transactionType : TransactionType, tokenAddress : address,  msg.sender : address) {

}

procedure checkBeneficiary(scriptHash : bytes32, beneficiary: address) {

}

procedure checkVote(scriptHash : bytes32, party : address) {

}

procedure addFundsToTransaction(scriptHash : bytes32, msg.value : uint256) {

}

procedure getAllTransactionsForParty (partyAddress : address){

}


procedure execute( calldataSigV : [int] uint8, calldataSigR : [int] bytes32, calldataSigS : [int] bytes32,
scriptHash : bytes32,  calldataDestinations : [int] address, calldataAmounts : [int] uint256) {

}

procedure getTransactionHash(scriptHash : bytes32,  destinations : [int] address,
amounts : [int] uint256) {

}

procedure calculateRedeemScriptHash(uniqueId : bytes20, threshold : uint8, timeoutHours : uint32,
buyer : address, seller : address, moderator : address, tokenAddress : address ) {

}