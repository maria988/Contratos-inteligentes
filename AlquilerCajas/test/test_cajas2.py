
import pytest

import brownie

CAJAS = 2
INITIAL_VALUE = 100
MENS = 20
TIEMPO_DISFRUTE = 30

TIEMPO_PAGAR = 10
FIANZA = 10

@pytest.fixture
def cajas2_contract(Cajas2, accounts):
    yield Cajas2.deploy(CAJAS,MENS,TIEMPO_DISFRUTE,TIEMPO_PAGAR,FIANZA,{'from': accounts[0]})

def test_inicial(cajas2_contract,accounts):
    assert cajas2_contract.fianza() == FIANZA
    assert cajas2_contract.tienda() == accounts[0]
    assert cajas2_contract.cajas() == CAJAS
    assert cajas2_contract.mensualidad() == MENS
    assert cajas2_contract.tiempo_disfrute()== TIEMPO_DISFRUTE
    assert cajas2_contract.tiempo_pagar() == TIEMPO_PAGAR
    
def test_events(cajas2_contract, accounts):
    cajas2_contract.alquilar({'from': accounts[1],'value':30})
    cajas2_contract.asignarllave(213,0,{'from': accounts[0]})
    tx1 = cajas2_contract.cambio(0)
    cajas2_contract.alquilar({'from': accounts[2],'value':30})
    cajas2_contract.asignarllave(215,1,{'from': accounts[0]})
    tx2 = cajas2_contract.cambio(1)
    
    assert len(tx1.events) == 2
    assert tx1.events[0]['emisor'] == accounts[1]
    assert tx1.events[0]['receptor']== accounts[0]
    assert tx1.events[0]['valor']== 20
    assert tx1.events[1]['receptor'] == accounts[1]
    assert tx1.events[1]['emisor'] == accounts[0]
    assert tx1.events[1]['clave_'] == 213
    
    assert len(tx2.events) == 2
    assert tx2.events[0]['emisor'] == accounts[2]
    assert tx2.events[0]['receptor']== accounts[0]
    assert tx2.events[0]['valor']== 20
    assert tx2.events[1]['receptor'] == accounts[2]
    assert tx2.events[1]['emisor'] == accounts[0]
    assert tx2.events[1]['clave_'] == 215


def test_failed_transactions(cajas2_contract, accounts):
    # Try to set the storage to a negative amount
    cajas2_contract.alquilar({'from': accounts[3],'value':30})
    cajas2_contract.alquilar({'from': accounts[1],'value':30})
    with brownie.reverts("Suficientes cajas"):
        cajas2_contract.alquilar( {"from": accounts[4],'value':30})
