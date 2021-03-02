

import pytest

import brownie

INITIAL_VALUE = 4


@pytest.fixture
def bizum_contract(Bizum1, accounts):
    yield Bizum1.deploy({'from': accounts[0],'value':INITIAL_VALUE})

def test_inicial(bizum_contract, accounts):
    bizum_contract.balance() == INITIAL_VALUE
    bizum_contract.titular() == accounts[0]
    
def test_events(bizum_contract, accounts):
    
    assert bizum_contract.efectivo() ==INITIAL_VALUE
    bizum_contract.meterdinero({'from': accounts[0],'value':INITIAL_VALUE})
    assert bizum_contract.efectivo() == 2*INITIAL_VALUE
    tx1 = bizum_contract.pagarme(accounts[0], {'from': accounts[1],'value':10})
    tx2 = bizum_contract.pagar(accounts[1], 10,{'from':accounts[0]})
    tx3 = bizum_contract.sacardinero(2,{'from': accounts[0]})
    tx4 = bizum_contract.destruir({'from': accounts[0]})
    
    assert len(tx1.events) == 1
    assert tx1.events[0]['emisor'] == accounts[1]
    assert tx1.events[0]['receptor']== accounts[0]
    assert tx1.events[0]['valor']== 10

    assert len(tx2.events) == 1
    assert tx2.events[0]['emisor'] == accounts[0]
    assert tx2.events[0]['receptor']== accounts[1]
    assert tx2.events[0]['valor']== 10
    
    
    assert len(tx3.events) == 1
    assert tx3.events[0]['emisororden'] == accounts[0]
    assert tx3.events[0]['valor'] == 2
    
    assert len(tx4.events) == 1
    assert tx4.events[0]['emisororden'] == accounts[0]
    assert tx4.events[0]['valor'] == 6
    
def test_failed_transactions(bizum_contract, accounts):
    
    with brownie.reverts("Receptor titular"):
        bizum_contract.pagarme(accounts[1],{'from':accounts[0],'value':200})
    
    with brownie.reverts("Emisor no titular"):
        bizum_contract.pagarme(accounts[0],{'from':accounts[0],'value':200})
        
    with brownie.reverts("Positivo"):
        bizum_contract.pagarme(accounts[0],{'from':accounts[1],'value':0})
    
    with brownie.reverts("Emisor titular"):
        bizum_contract.pagar(accounts[0],10,{'from':accounts[1],'value':0})
        
    with brownie.reverts("Receptor no titular"):
        bizum_contract.pagar(accounts[0],10,{'from':accounts[0],'value':0})
        
    with brownie.reverts("Suficiente"):
        bizum_contract.pagar(accounts[1],10,{'from':accounts[0],'value':0})
        
    with brownie.reverts("Positivo"):
        bizum_contract.meterdinero({'from':accounts[1],'value':0})
        
    with brownie.reverts("Titular"):
        bizum_contract.meterdinero({'from':accounts[1],'value':10})
        
    with brownie.reverts("Suficiente"):
        bizum_contract.sacardinero(10,{'from':accounts[1]})
        
    with brownie.reverts("Titular"):
        bizum_contract.sacardinero(2,{'from':accounts[1]})
        
    with brownie.reverts("Titular"):
        bizum_contract.destruir({'from':accounts[1]})
    
