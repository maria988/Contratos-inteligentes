
import pytest

import brownie

INITIAL_VALUE = 100
MENS = 200
TIEMPO = 30
TIEMPO_CONTRATO = 90

@pytest.fixture
def adv_storage_contract(Alquiler1, accounts):
    yield Alquiler1.deploy(MENS,TIEMPO,TIEMPO_CONTRATO,{'from': accounts[0],'value':INITIAL_VALUE})
    
def test_events(adv_storage_contract, accounts):
    tx1 = adv_storage_contract.alquilar({'from': accounts[1],'value':300})
    tx3 = adv_storage_contract.pagar({'from':accounts[1],'value': 200})
    

    
    assert len(tx1.events) == 1
    assert tx1.events[0]['emisor'] == accounts[1]
    assert tx1.events[0]['receptor']== accounts[0]
    assert tx1.events[0]['valor']== 200
    
    assert tx3
