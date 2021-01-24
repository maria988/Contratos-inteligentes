
import pytest

import brownie

PUNTOS1 = 10
DESCUENTO1 = 10
CUPON1 = "DESC10"
PUNTOS2 = 30
DESCUENTO2 = 30
CUPON2 = "DESC30"
PUNTOS3 = 50
DESCUENTO3 = 50
CUPON3 = "DESC50"
APUNTOS = 10



@pytest.fixture
def cupones_contract(Cupones, accounts):
    yield Cupones.deploy(PUNTOS1,DESCUENTO1,PUNTOS2,DESCUENTO2,PUNTOS3,DESCUENTO3,CUPON1,CUPON2,CUPON3,APUNTOS,{'from': accounts[0]})

def test_inicial(cupones_contract,accounts):
    assert cupones_contract.empresa() == accounts[0]
    assert cupones_contract.premios(1) == (PUNTOS1,DESCUENTO1)
    assert cupones_contract.premios(2) == (PUNTOS2,DESCUENTO2)
    assert cupones_contract.premios(3) == (PUNTOS3,DESCUENTO3)
    assert cupones_contract.cupones(1) == CUPON1
    assert cupones_contract.cupones(2) == CUPON2
    assert cupones_contract.cupones(3) == CUPON3
    assert cupones_contract.apuntos() == APUNTOS
    
    
def test_events(cupones_contract,accounts):
    cupones_contract.nuevocliente({'from':accounts[1]})
    cupones_contract.compra({'from':accounts[1],'value':500})
    tx1 = cupones_contract.canjearpuntos({'from':accounts[1]})
    
    assert (len(tx1.events) == 1)
    assert tx1.events[0]['emisor'] == accounts[0]
    assert tx1.events[0]['receptor'] == accounts[1]
    assert tx1.events[0]['codigodescuento'] == CUPON3
    
    cupones_contract.usar_cupones(CUPON3,{'from':accounts[1]})
    tx2 = cupones_contract.compra({'from':accounts[1],'value':300})
    
    assert(len(tx2.events)==1)
    assert tx2.events[0]['emisor'] == accounts[0]
    assert tx2.events[0]['beneficiario'] == accounts[1]
    assert tx2.events[0]['valor'] == 150
    
    
    cupones_contract.dejardesercliente({'from':accounts[1]})
    
    
def test_failed_transactions(cupones_contract, accounts):
    cupones_contract.nuevocliente({'from':accounts[1]})
    with brownie.reverts("Cliente"):
        cupones_contract.canjearpuntos({'from': accounts[2]})
    
    
    with brownie.reverts("Numero de descuento"):
        cupones_contract.canjearpuntos({'from': accounts[1]})
        
        
    with brownie.reverts("Cliente"):
        cupones_contract.usar_cupones("123",{'from': accounts[2]})
        
    with brownie.reverts("Cupon valido"):
        cupones_contract.usar_cupones("213",{'from': accounts[1]})
    
    with brownie.reverts("Tiene el cupon"):
        cupones_contract.usar_cupones(CUPON1,{'from': accounts[1]})
    
    with brownie.reverts("Cliente"):
        cupones_contract.compra({'from': accounts[0],'value':123})
    
    
    with brownie.reverts("Positivo"):
        cupones_contract.compra({'from': accounts[1],'value':0})
        
        
    with brownie.reverts("Cliente"):
        cupones_contract.dejardesercliente({'from': accounts[0]})
