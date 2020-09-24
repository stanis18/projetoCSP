type Ref;
const null : Ref; //Declarando um tipo null para referencias.. 
type string; //declarando um tipo string
type bytes20;
type bytes32;
type uint8;
type uint32;
type uint256;

type Transaction = <G>[Ref, Field G] G;

type address; 
const unique zeroAddress: address;
const unique validAddress: address;

type Status;
const unique FUNDED: Status;
const unique RELEASED: Status;

type TransactionType;
const unique ETHER: TransactionType;
const unique TOKEN: TransactionType;

var Transaction.value : [Ref] uint256;
var Transaction.lastModified : [Ref] uint256;
var Transaction.status : [Ref] Status;
var Transaction.transactionType : [Ref] TransactionType;
var Transaction.threshold : [Ref] uint8;
var Transaction.timeoutHours : [Ref] uint32;
var Transaction.buyer : [Ref] address;
var Transaction.seller : [Ref] address;
var Transaction.tokenAddress : [Ref] address; 
var Transaction.moderator : [Ref] address;
var Transaction.released : [Ref] uint256;
var Transaction.noOfReleases : [Ref] uint256; 
var Transaction.isOwner : [Ref] [address] bool;
var Transaction.voted : [Ref] [bytes32] bool;
var Transaction.beneficiaries : [Ref] [address] bool;

//-------------------------------------------------------------------------

type Field G; 
var Transactions : [Ref] Transaction; //map para referenciar as transacoes

var PartyVsTransaction : [address] [int] bytes32; //mapa de para um array de bytes32

var transactionCount : int;


//-------------------------------------------------------------------------

procedure addTransaction(buyer : address, seller : address, moderator : address, threshold : uint8, 
timeoutHours : uint32, scriptHash: bytes32, uniqueId : bytes20, msg.sender : address, msg.value : uint256 ) {

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



type StateType; //declarando um tipo genérico para o enum 
const unique PartyProvisioned: StateType;
const unique ItemListed: StateType;
const unique CurrentSaleFinalized: StateType;


var Bazaar.State : [Ref] StateType;
var Bazaar.InstancePartyA : [Ref] address;
var Bazaar.PartyABalance : [Ref] int;
var Bazaar.InstancePartyB : [Ref] address;
var Bazaar.PartyBBalance : [Ref] int;
var Bazaar.InstanceBazaarMaintainer : [Ref] address;
var Bazaar.CurrentSeller : [Ref] address;
var Bazaar.ItemName : [Ref] string;
var Bazaar.ItemPrice : [Ref] int;
var Bazaar.CurrentContractAddress : [Ref] address;
var Bazaar.currentItemListing : [Ref] Ref;

// Added
procedure main ()
modifies Bazaar.InstanceBazaarMaintainer, Bazaar.PartyABalance, Bazaar.PartyBBalance, Bazaar.InstancePartyA, Bazaar.InstancePartyB, Bazaar.CurrentContractAddress, Bazaar.State;
{
var ref1 : Ref;
var ref2 : Ref;

var addrA : address;
var addrB : address;
var addr : address;
assume addrA != addrB;

call ref1 := constructorBazzar(addrA, 0, addrB, 0, addr, addr);
call ref2 := constructorBazzar(addrA, 0, addrB, 0, addr, addr);

assume ref1 != ref2;

Bazaar.PartyABalance [ref1] := 10;
assert Bazaar.PartyABalance [ref2] == 0;
}


procedure constructorBazzar (partyA : address, balanceA : int, partyB : address, balanceB : int, msg.sender : address, address.this: address) returns(this: Ref)
modifies Bazaar.InstanceBazaarMaintainer, Bazaar.PartyABalance, Bazaar.PartyBBalance, Bazaar.InstancePartyA, Bazaar.InstancePartyB, Bazaar.CurrentContractAddress, Bazaar.State;
requires balanceA >= 0; 
requires balanceB >= 0; 
requires partyA != partyB;
ensures Bazaar.State [this] == PartyProvisioned; 
ensures Bazaar.CurrentContractAddress [this] == address.this;
ensures Bazaar.PartyABalance [this] == balanceA; // Modified
ensures Bazaar.PartyBBalance [this] == balanceB; // Modified
{
    assume this != null;
    
    Bazaar.InstanceBazaarMaintainer [this] := msg.sender;
    Bazaar.PartyABalance [this] := balanceA;
    Bazaar.PartyBBalance [this] := balanceB;
    Bazaar.InstancePartyA [this] := partyA;
    Bazaar.InstancePartyB [this] := partyB;
    Bazaar.CurrentContractAddress [this] := address.this;
    Bazaar.State [this] := PartyProvisioned;
}

function HasBalance(buyer: address, itemPrice : int, Bazaar.InstancePartyA: address, Bazaar.PartyABalance : int,
 Bazaar.InstancePartyB : address, Bazaar.PartyBBalance : int)
  returns (bool) {
      (
  (buyer == Bazaar.InstancePartyA && Bazaar.PartyABalance >= itemPrice)  || 
  (buyer == Bazaar.InstancePartyB  &&  Bazaar.PartyBBalance >= itemPrice)

  )
}

procedure UpdateBalance(sellerParty : address, buyerParty : address, itemPrice : int, this: Ref)
modifies Bazaar.State, Bazaar.PartyABalance, Bazaar.PartyBBalance;
requires itemPrice >= 0; 
requires this != null;
ensures Bazaar.State [this] == CurrentSaleFinalized; 
{
    call ChangeBalance(sellerParty, itemPrice, this);
    call ChangeBalance(buyerParty, -itemPrice, this);
    Bazaar.State [this] := CurrentSaleFinalized;
}

procedure ChangeBalance(party : address, balance : int, this: Ref)
requires this != null;
modifies Bazaar.PartyABalance, Bazaar.PartyBBalance; {

    if(party ==  Bazaar.InstancePartyA [this] ){
        Bazaar.PartyABalance [this] := Bazaar.PartyABalance [this] + balance;
    }
    if(party == Bazaar.InstancePartyB [this] ){
        Bazaar.PartyBBalance [this] := Bazaar.PartyBBalance [this] + balance;
    }
}

procedure ListItem(itemName : string, itemPrice: int, msg.sender : address,  this: Ref)
requires itemPrice >= 0; requires this != null;
modifies Bazaar.CurrentSeller, Bazaar.State, Bazaar.currentItemListing;
modifies ItemListing.Seller, ItemListing.InstanceBuyer, ItemListing.ParentContract, ItemListing.ItemName,ItemListing.ItemPrice, ItemListing.PartyA, ItemListing.PartyB, ItemListing.State;
ensures Bazaar.State [this] == ItemListed; {
    
    var refItemListing : Ref;
   
    Bazaar.CurrentSeller [this] :=  msg.sender;

    call refItemListing := constructorItemListing(itemName, itemPrice, Bazaar.CurrentSeller [this], 
    	Bazaar.CurrentContractAddress [this], Bazaar.InstancePartyA [this], Bazaar.InstancePartyB [this]); 

    Bazaar.currentItemListing [this] := refItemListing;  
   
    Bazaar.State [this] := ItemListed;
}

// ----------Modelagem do contrato ItemListing---------- 

const unique ItemAvailable: StateType;
const unique ItemSold: StateType;

var ItemListing.Seller : [Ref] address;
var ItemListing.InstanceBuyer : [Ref] address;
var ItemListing.ParentContract : [Ref] address;
var ItemListing.ItemName : [Ref] string;
var ItemListing.ItemPrice : [Ref] int;
var ItemListing.PartyA : [Ref] address;
var ItemListing.PartyB : [Ref] address;
var ItemListing.State : [Ref] StateType;


procedure constructorItemListing(itemName : string, itemPrice : int, seller : address, parentContractAddress : address, partyA : address, partyB: address) returns(this: Ref)
modifies ItemListing.Seller, ItemListing.InstanceBuyer, ItemListing.ParentContract, ItemListing.ItemName, ItemListing.ItemPrice, ItemListing.PartyA, ItemListing.PartyB, ItemListing.State;
ensures ItemListing.State [this] == ItemAvailable;
ensures this != null; { 
    
    assume this != null;
    
    ItemListing.Seller [this] := seller;
    ItemListing.ParentContract [this] := parentContractAddress;
    ItemListing.ItemName [this] := itemName;
    ItemListing.ItemPrice [this] := itemPrice;
    ItemListing.PartyA [this] := partyA;
    ItemListing.PartyB [this] := partyB;
    ItemListing.State [this] := ItemAvailable;
}


procedure BuyItem(msg.sender : address, thisBazzar: Ref, thisItemListing: Ref) 
modifies ItemListing.State, ItemListing.InstanceBuyer;
modifies Bazaar.State, Bazaar.PartyABalance, Bazaar.PartyBBalance;
requires thisBazzar != null; requires thisItemListing != null;
requires ItemListing.Seller [thisItemListing] != ItemListing.InstanceBuyer [thisItemListing];
requires ItemListing.ItemPrice [thisItemListing] >= 0;
requires HasBalance(ItemListing.InstanceBuyer [thisItemListing], ItemListing.ItemPrice [thisItemListing], Bazaar.InstancePartyA [thisBazzar], Bazaar.PartyABalance [thisBazzar], Bazaar.InstancePartyB [thisBazzar], Bazaar.PartyBBalance [thisBazzar]);
ensures ItemListing.State [thisItemListing] == ItemSold; 
{

    ItemListing.InstanceBuyer [thisItemListing] := msg.sender;

    call UpdateBalance(ItemListing.Seller [thisItemListing], ItemListing.InstanceBuyer [thisItemListing], ItemListing.ItemPrice [thisItemListing], thisBazzar);

    ItemListing.State [thisItemListing] := ItemSold;
}
