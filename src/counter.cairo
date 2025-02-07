#[starknet::interface]
pub trait ICount<TContractState>{
    fn increment(ref self: @TContractState);
    fn decrement( ref self: @TContractState);
    fn get_counter(self: @TContractState) -> u32;
    fn reset_counter(ref self: @TContractState);
}

#[starknet::contract]
pub mod Counting{
   use starknet::{ContractAddress, get_caller_address};
   use starknet::storage::
   {StoragePointerWriteAccess, StoragePointerReadAccess};

    #[storage]
    struct Storage{
        counter: u32
    }
    #[derive(Drop, starknet::Event)]
    struct CounterIncrease{
        counter: u32,
    }

    #[derive(Drop, starknet::Event)]
    struct CounterDecrease{
        counter: u32,
    }
     #[event]
    #[derive(Drop, starknet:: Event)]
    enum Event{
        CounterIncrease: CounterIncrease,
        CounterDecrease: CounterDecrease,
    }

     #[constructor]
    fn constructor(ref self: ContractState, initial_counter: u32, owner: ContractAddress){
        self.counter.write(initial_counter);
        self.counter.write(owner);
    }

    #[abi(embed_v0)]
    impl CounterImpl of super::ICount<ContractState> {
        fn increment(ref self: ContractState){
            let current_counter = self.counter.read();
            let new_counter = current_counter+ 1;
            self.counter.write(new_counter);
            self.emit(CounterIncrease{counter: new_counter});
        }
        fn decrement(ref self: ContractState){
            let current_counter = self.counter.read();
            let new_counter = current_counter - 1;
            assert(new_counter > 0, "Counter cannot be negative");
            self.counter.write(new_counter);
            self.emit(CounterDecrease{Counter: new_counter});
        }
        fn get_counter(self: @ContractState) -> u32{
            self.counter.read()
        }

        fn reset_counter(ref self: ContractState){
            let caller  = get_caller_address();
            let owner = self.owner.read();
            assert(caller == owner, 'Not the owner');
            self.counter.write(0);
        }
        
    }
}