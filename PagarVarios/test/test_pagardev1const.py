
import pytest

import brownie
import time
PRECIO = 100

@pytest.fixture
def pagardev1const_contract(pagarvariosdevolver1constante, accounts):
    yield pagarvariosdevolver1constante.deploy(PRECIO,{'from': accounts[0]})

def test_inicial(pagardev1const_contract,accounts):
    assert pagardev1const_contract.empresa() == accounts[0]
    assert pagardev1const_contract.precio() == PRECIO

def test_event1(pagardev1const_contract,accounts):
    tx1 = pagardev1const_contract.pagar(accounts[0],{'from':accounts[1],'value':20})
    tx2 = pagardev1const_contract.pagar(accounts[0],{'from':accounts[2],'value':50})
    tx3 = pagardev1const_contract.pagar(accounts[0],{'from':accounts[3],'value':60})
    
    assert pagardev1const_contract.pagado()
    
    assert len(tx1.events)==1
    assert tx1.events[0]['emisor'] == accounts[1]
    assert tx1.events[0]['receptor'] == accounts[0]
    assert tx1.events[0]['valor'] == 20
    
    assert len(tx2.events) == 1
    assert tx2.events[0]['emisor'] == accounts[2]
    assert tx2.events[0]['receptor'] == accounts[0]
    assert tx2.events[0]['valor'] == 50
    
    assert len(tx3.events) == 2
    assert tx3.events[0]['emisor'] == accounts[3]
    assert tx3.events[0]['receptor'] == accounts[0]
    assert tx3.events[0]['valor'] == 30
    assert tx3.events[1]['emisor'] == accounts[0]
    assert tx3.events[1]['receptor'] == accounts[3]
    assert tx3.events[1]['valor'] == 30
    pagardev1_contract.producto(True,{'from':accounts[1]})

def test_event2(pagardev1const_contract,accounts):
    pagardev1const_contract.pagar(accounts[0],{'from':accounts[1],'value':20})
    pagardev1const_contract.pagar(accounts[0],{'from':accounts[2],'value':50})
    pagardev1const_contract.pagar(accounts[0],{'from':accounts[3],'value':30})
    assert pagardev1const_contract.pagado()
    
    time.sleep(4)
    
    tx1 = pagardev1const_contract.producto(False,{'from':accounts[1]})
    assert len(tx1.events) == 3
    assert tx1.events[0]['receptor'] == accounts[1]
    assert tx1.events[0]['valor'] == 20
    assert tx1.events[1]['receptor'] == accounts[2]
    assert tx1.events[1]['valor'] == 50
    assert tx1.events[2]['receptor'] == accounts[3]
    assert tx1.events[2]['valor'] == 30
    assert tx1.events[1]['emisor'] == accounts[0]
    
def test_failed_transactions(pagardev1const_contract, accounts):
    
    with brownie.reverts("Empresa"):
        pagardev1const_contract.pagar(accounts[1],{'from':accounts[1]})
        
    with brownie.reverts("Cliente"):
        pagardev1const_contract.pagar(accounts[0],{'from':accounts[0]})
    
    pagardev1const_contract.pagar(accounts[0],{'from':accounts[1],'value':50})
    with brownie.reverts("Pagado"):
        pagardev1const_contract.producto(False,{'from':accounts[1]})
    
    pagardev1const_contract.pagar(accounts[0],{'from':accounts[2],'value':50})
    with brownie.reverts("Ha pagado"):
        pagardev1const_contract.producto(False,{'from':accounts[3]})
    with brownie.reverts("Posibilidades"):
        pagardev1const_contract.producto(False,{'from':accounts[2]})
