
use starknet::ContractAddress;
use snforge_std::{declare,ContractClassTrait, DeclareResultTrait};

use count::{ICounterDispatcher, ICounterDispatcherTrait};

fn owner()-> ContractAddress{
    'owner'.try_into().unwrap()
}

fn deploy_counter(initial_count: u32)->ICounterDispatcher{
let contract_class = declare("Counter").unwrap().contract_class();

let mut calldata= array![];
initial_count.serialize(ref calldata);
owner().serialize(ref calldata);

let (contract_address, _)= contract_class.deploy(@calldata).unwrap();

ICounterDispatcher{contract_address}
}

#[test]
fn test_deploy_contract(){
    let initial_count= 3;
    let counter = deploy_counter(initial_count);

    let current_count= counter.get_counter();

    assert(current_count == initial_count, 'Not looking good');

}

#[test]
#[should_panic]
fn test_increament_counter_overflow(){
    let initial_count= 0xffffffff; // max value of u32
    let counter = deploy_counter(initial_count);

    counter.increase_counter();
    
}

#[test]
fn test_increament (){
    let initial_count = 3;
    let counter = deploy_counter(initial_count);
    let current_count = counter.get_counter();
    let new_count = current_count + 1;
    assert(new_count == current_count + 1, 'Increment failed');
}

#[test]
fn test_decreament(){
    let initial_count = 3;
    let counter = deploy_counter(initial_count);
    let current_count = counter.get_counter();
    let new_count = current_count - 1;
    assert(new_count == current_count -1, 'decrement failed');
}

#[test]
#[should_panic]
fn test_decreament_overflow(){
    let initial_count = 0;
    let counter = deploy_counter(initial_count);
    counter.decrease_counter();
}

#[test]
fn test_reset_counter(){
    let initial_count = 3;
    let counter = deploy_counter(initial_count);
    counter.reset_counter();
    let current_count = counter.get_counter();
    assert(current_count == 0, 'reset failed');
}