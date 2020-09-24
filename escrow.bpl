type Ref;
type string; //declarando um tipo string
type bytes20;
type bytes32;
type Field G; 

//type x = int where 0 < x ;

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
var value : Field int;
var lastModified : Field int;
var status : Field Status;
var transactionType : Field TransactionType;
var threshold : Field int;
var timeoutHours : Field int;
var buyer : Field address;
var seller : Field address;
var tokenAddress : Field address; 
var moderator : Field address;
var released : Field int;
var noOfReleases : Field int; 
var isOwner : Field [address] bool;
var voted : Field [bytes32] bool;
var beneficiaries : Field [address] bool;

//-------------------------------------------------------------------------
//Memory

var Transactions : [bytes32] Transaction; //map para referenciar as transacoes

var PartyVsTransaction : [address] [int] bytes32; //mapa de para um array de bytes32

var transactionCount : int;


//-----------------------------Modifiers--------------------------------------------

 function transactionDoesNotExistModifier(scriptHash : bytes32, this : Ref, transactionsMap : [bytes32] Transaction) returns (bool) {
    (transactionsMap[scriptHash] == null)
}

function transactionExistsModifier(scriptHash : bytes32, this : Ref, transactionsMap : [bytes32] Transaction) returns (bool) {
    (transactionsMap[scriptHash] != null)
}

function inFundedStateModifier(scriptHash : bytes32) returns (bool) {
       true
}

function fundsExistModifier(scriptHash : bytes32) returns (bool) {
    true
}

function nonZeroAddressModifier(addressToCheck : address) returns (bool) {
    true
}

function checkTransactionTypeModifier(scriptHash : bytes32, transactionType : TransactionType) returns (bool) {
    true
}

function onlyBuyerModifier(scriptHash : bytes32) returns (bool) {
    true
}

//-------------------------------------------------------------------------


procedure addTransaction(buyer : address, seller : address, moderator : address, threshold : int, 
timeoutHours : int, scriptHash: bytes32, uniqueId : bytes20, msg.sender : address, msg.value : int, this : Ref )
requires transactionDoesNotExistModifier(scriptHash, this, Transactions); 
requires nonZeroAddressModifier(buyer);
requires nonZeroAddressModifier(seller);{

    
    call addTransaction_ (buyer, seller, moderator, threshold, timeoutHours, scriptHash, msg.value, 
    uniqueId, ETHER, zeroAddress, msg.sender);
}

procedure addTokenTransaction(buyer : address, seller : address, moderator : address, threshold : int, 
timeoutHours : int, scriptHash: bytes32, value : int, uniqueId : bytes20, msg.sender : address ) {

    call addTransaction_ (buyer, seller, moderator, threshold, timeoutHours, scriptHash, value, 
    uniqueId, TOKEN, zeroAddress, msg.sender);
}



procedure addTransaction_ (buyer : address, seller : address, moderator : address, threshold : int,
timeoutHours : int, scriptHash : bytes32, value : int, uniqueId : bytes20, 
transactionType : TransactionType, tokenAddress : address,  msg.sender : address) {
   
   var this : Ref;
   var newTransaction : Transaction;
   
   assume (buyer != seller);
   assume (value > 0);
   assume (threshold > 0);
   assume (threshold <= 3);
   assume (threshold == 1 || moderator != zeroAddress);
   assume (scriptHash == calculateRedeemScriptHash(uniqueId,threshold,timeoutHours, buyer, seller, moderator, tokenAddress ));

  newTransaction[this, buyer] := Field buyer;

    
}

function calculateRedeemScriptHash(uniqueId : bytes20, threshold : int, timeoutHours : int, buyer : address,
seller : address, moderator : address, tokenAddress : address) returns (bytes32);
    



procedure checkBeneficiary(scriptHash : bytes32, beneficiary: address) {

}

procedure checkVote(scriptHash : bytes32, party : address) {

}

procedure addFundsToTransaction(scriptHash : bytes32, msg.value : int) {

}

procedure getAllTransactionsForParty (partyAddress : address){

}


procedure execute( calldataSigV : [int] int, calldataSigR : [int] bytes32, calldataSigS : [int] bytes32,
scriptHash : bytes32,  calldataDestinations : [int] address, calldataAmounts : [int] int) {

}

procedure getTransactionHash(scriptHash : bytes32,  destinations : [int] address,
amounts : [int] int) {

}

