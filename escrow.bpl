type Ref;
const null : Ref; //Declarando um tipo null para referencias.. 
type string; //declarando um tipo string
type bytes20;
type bytes32;
const alloc : bytes32;
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

var Transaction.value : [Ref] int;
var Transaction.lastModified : [Ref] int;
var Transaction.status : [Ref] Status;
var Transaction.transactionType : [Ref] TransactionType;
var Transaction.threshold : [Ref] int;
var Transaction.timeoutHours : [Ref] int;
var Transaction.buyer : [Ref] address;
var Transaction.seller : [Ref] address;
var Transaction.tokenAddress : [Ref] address; 
var Transaction.moderator : [Ref] address;
var Transaction.released : [Ref] int;
var Transaction.noOfReleases : [Ref] int; 
var Transaction.isOwner : [Ref] [address] bool;
var Transaction.voted : [Ref] [bytes32] bool;
var Transaction.beneficiaries : [Ref] [address] bool;

//-------------------------------------------------------------------------
//Memory

var transactions : [bytes32] Ref; //map para referenciar as transacoes

var partyVsTransaction : [address] [int] bytes32; //mapa de para um array de bytes32

var transactionCount : int;


//-----------------------------Modifiers--------------------------------------------

procedure transactionDoesNotExistModifier(scriptHash : bytes32, transactionsMap : [bytes32] Ref) returns (ret: bool) {
    ret := Transaction.value [ transactionsMap[scriptHash] ] == 0;
}

procedure transactionExistsModifier(scriptHash : bytes32, this : Ref, transactionsMap : [bytes32] Ref) returns (ret: bool) {
     ret := Transaction.value [ transactionsMap[scriptHash] ] != 0;
}

procedure inFundedStateModifier(scriptHash : bytes32, transactionsMap : [bytes32] Ref) returns (ret: bool) {
       ret := Transaction.status [ transactionsMap[scriptHash] ] == FUNDED;
}

procedure fundsExistModifier(scriptHash : bytes32, transactionsMap : [bytes32] Ref) returns (ret : bool) {
     ret := (Transaction.value [ transactionsMap[scriptHash] ] - Transaction.released [ transactionsMap[scriptHash] ] > 0);
}

function nonZeroAddressModifier(addressToCheck : address, zAddress : address) returns (bool) {
    (addressToCheck != zAddress)
}

procedure checkTransactionTypeModifier(scriptHash : bytes32, transactionType : TransactionType, transactionsMap : [bytes32] Ref) returns (ret : bool) {
    ret := Transaction.transactionType [ transactionsMap[scriptHash] ] == transactionType;
}

procedure onlyBuyerModifier(scriptHash : bytes32, msg.sender : address, transactionsMap : [bytes32] Ref) returns (ret : bool) {
     ret := Transaction.buyer [ transactionsMap[scriptHash] ] == msg.sender;
}

//-----------------------------Event--------------------------------------------
var Event.scriptHash : [Ref] bytes32;
var Event.msg.senderEvent : [Ref] address;
var Event.msg.valueEvent : [Ref] int;

//Field (scriptHash, msg.sender, msg.value);

//-------------------------------------------------------------------------

procedure addTransaction(buyer : address, seller : address, moderator : address, threshold : int, 
timeoutHours : int, scriptHash: bytes32, uniqueId : bytes20, msg.sender : address, msg.value : int, block.timestamp : int ) returns(thisEvent: Ref)
modifies transactions, transactionCount, partyVsTransaction, Transaction.value, Transaction.lastModified, Transaction.status, Transaction.transactionType,
Transaction.threshold, Transaction.timeoutHours, Transaction.buyer, Transaction.seller,
Transaction.tokenAddress, Transaction.moderator, Transaction.released, Transaction.noOfReleases,
Transaction.isOwner, Transaction.voted, Transaction.beneficiaries,  Event.scriptHash, Event.msg.senderEvent,  Event.msg.valueEvent;
requires nonZeroAddressModifier(buyer, zeroAddress);
requires nonZeroAddressModifier(seller, zeroAddress);{

    
    var returnTransactionDoesNotExistModifier : bool;
    call returnTransactionDoesNotExistModifier := transactionDoesNotExistModifier(scriptHash, transactions);
    assume(returnTransactionDoesNotExistModifier);
    
    call addTransaction_ (buyer, seller, moderator, threshold, timeoutHours, scriptHash, msg.value, 
    uniqueId, ETHER, zeroAddress, msg.sender, block.timestamp);

    assume thisEvent != null;

    Event.scriptHash [thisEvent] := scriptHash;
    Event.msg.senderEvent [thisEvent] := msg.sender;
    Event.msg.valueEvent [thisEvent] := msg.value;

}

procedure addTokenTransaction(buyer : address, seller : address, moderator : address, threshold : int, 
timeoutHours : int, scriptHash: bytes32, value : int, uniqueId : bytes20, msg.sender : address, block.timestamp : int ) 
modifies transactions, transactionCount, partyVsTransaction, Transaction.value, Transaction.lastModified, Transaction.status, Transaction.transactionType,
Transaction.threshold, Transaction.timeoutHours, Transaction.buyer, Transaction.seller,
Transaction.tokenAddress, Transaction.moderator, Transaction.released, Transaction.noOfReleases,
Transaction.isOwner, Transaction.voted, Transaction.beneficiaries;{

    call addTransaction_ (buyer, seller, moderator, threshold, timeoutHours, scriptHash, value, 
    uniqueId, TOKEN, zeroAddress, msg.sender, block.timestamp);
}


procedure addTransaction_ (buyer : address, seller : address, moderator : address, threshold : int,
timeoutHours : int, scriptHash : bytes32, value : int, uniqueId : bytes20, 
transactionType : TransactionType, tokenAddress : address,  msg.sender : address, block.timestamp : int) 
modifies transactions, transactionCount, partyVsTransaction, Transaction.value, Transaction.lastModified, Transaction.status, 
Transaction.transactionType, Transaction.threshold, Transaction.timeoutHours, Transaction.buyer, Transaction.seller,
Transaction.tokenAddress, Transaction.moderator, Transaction.released, Transaction.noOfReleases,
Transaction.isOwner, Transaction.voted, Transaction.beneficiaries;{
   
   var this : Ref;
   var newTransaction : Transaction;

   var buyerIndex : int;
   var sellerIndex : int;
   
   assume (buyer != seller);
   assume (value > 0);
   assume (threshold > 0);
   assume (threshold <= 3);
   assume (threshold == 1 || moderator != zeroAddress);
   assume (scriptHash == calculateRedeemScriptHash(uniqueId,threshold,timeoutHours, buyer, seller, moderator, tokenAddress ));

    assume this != null;
    Transaction.buyer [this] := buyer;
    Transaction.seller [this] := seller;
    Transaction.moderator [this] := moderator;
    Transaction.value [this] := value;
    Transaction.status [this] := FUNDED;
    Transaction.lastModified[this] :=  block.timestamp;
    Transaction.threshold[this] := threshold;
    Transaction.timeoutHours[this] :=  timeoutHours;
    Transaction.transactionType[this] := transactionType;
    Transaction.tokenAddress[this] := tokenAddress;
    Transaction.released[this] := 0;
    Transaction.noOfReleases[this] := 0;

    Transaction.isOwner[this] [buyer] := true;
    Transaction.isOwner[this] [seller] := true;

    if (threshold > 1) {
        assume(!Transaction.isOwner[this] [moderator] );
    }
    
    transactionCount := transactionCount + 1;

    havoc buyerIndex; 
    assume partyVsTransaction[buyer] [buyerIndex] != alloc;
    partyVsTransaction[buyer] [buyerIndex] := scriptHash;

    havoc sellerIndex; 
    assume partyVsTransaction[buyer] [sellerIndex] != alloc;
    partyVsTransaction[seller] [sellerIndex] := scriptHash;

    transactions [scriptHash] := this;
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

