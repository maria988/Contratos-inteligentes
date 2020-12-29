
import pytest

import brownie

INITIAL_VALUE = 4


@pytest.fixture
def adv_storage_contract(Bizum1, accounts):
    yield Bizum1.deploy({'from': accounts[0],'value':INITIAL_VALUE})
    
def test_events(adv_storage_contract, accounts):
    tx1 = adv_storage_contract.pagarme(accounts[0], {'from': accounts[1],'value':10})
    tx2 = adv_storage_contract.pagar(accounts[1], 10,{'from':accounts[0]})
    tx3 = adv_storage_contract.efectivo({'from':accounts[0]})
    tx4 = adv_storage_contract.sacardinero(2,{'from': accounts[0]})

    # Check log contents
    assert len(tx1.events) == 1
    assert tx1.events[0]['emisor'] == accounts[1]
    assert tx1.events[0]['receptor']== accounts[0]
    assert tx1.events[0]['valor']== 10

    assert len(tx1.events) == 1
    assert tx2.events[0]['emisor'] == accounts[0]
    assert tx2.events[0]['receptor']== accounts[1]
    assert tx2.events[0]['valor']== 10
    
    assert tx3 == 4
    
    assert len(tx4.events) == 1
    assert tx4.events[0]['emisororden'] == accounts[0]
    assert tx4.events[0]['valor'] == 2
    
