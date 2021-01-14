
import pytest

import brownie

DURACION = 10
DURACIONPERIODO = 3
RENTABILIDAD = 10
PENALIZACION = 70
CANTIDAD = 1000
CANTIDAD2 = 600


@pytest.fixture
def fondoInversion_contract(fondodeinversion, accounts):
    yield fondodeinversion.deploy(accounts[1],DURACION,DURACIONPERIODO,RENTABILIDAD,PENALIZACION,CANTIDAD,{'from': accounts[0]})

def test_inicial(fondoInversion_contract,accounts):
    assert fondoInversion_contract.banco() == accounts[0]
    assert fondoInversion_contract.duracionPeriodo() == DURACIONPERIODO
    assert fondoInversion_contract.rentabilidad() == RENTABILIDAD
    assert fondoInversion_contract.penalizacion() == PENALIZACION
    assert fondoInversion_contract.cliente() == accounts[1]
    assert fondoInversion_contract.cantidad() == CANTIDAD

def test_event(fondoInversion_contract,accounts):
    fondoInversion_contract.firmar({'from':accounts[1],'value':CANTIDAD})
    fondoInversion_contract.capital_actual(CANTIDAD2,{'from':accounts[0]})
    assert fondoInversion_contract.consultar({'from':accounts[1]}) == CANTIDAD2
    assert fondoInversion_contract.recuperaria({'from':accounts[1]}) == ((100-PENALIZACION)*CANTIDAD2)/100
    tx1 = fondoInversion_contract.sacar({'from':accounts[1]})
    fondoInversion_contract.devolver({'from':accounts[0],'value':((100-PENALIZACION)*CANTIDAD2)/100})
    assert len(tx1.events)==1
    assert tx1.events[0]['banco'] == accounts[0]
    assert tx1.events[0]['cliente'] == accounts[1]
    assert tx1.events[0]['cantidad'] == ((100-PENALIZACION)*CANTIDAD2)/100
    
    
def test_failed_transactions(fondoInversion_contract, accounts):
    
    with brownie.reverts("Cantidad exacta"):
        fondoInversion_contract.firmar({'from':accounts[1],'value':CANTIDAD2})
    
    with brownie.reverts("Cliente"):
        fondoInversion_contract.firmar({'from':accounts[8],'value':CANTIDAD})
        
    fondoInversion_contract.firmar({'from':accounts[1],'value':CANTIDAD})
    
    with brownie.reverts("No firmado"):
        fondoInversion_contract.firmar({'from':accounts[0],'value':CANTIDAD})
        
    with brownie.reverts("Banco"):
        fondoInversion_contract.cambiarPeriodo(CANTIDAD,{'from':accounts[7],'value':CANTIDAD})
        
    with brownie.reverts("Cantidad exacta"):
        fondoInversion_contract.cambiarPeriodo(CANTIDAD,{'from':accounts[0]})
        
    with brownie.reverts("Periodo cumplido"):
        fondoInversion_contract.cambiarPeriodo(CANTIDAD,{'from':accounts[0],'value':(CANTIDAD*RENTABILIDAD)/100})   
        
    with brownie.reverts("Cantidad exacta"):
        fondoInversion_contract.cambiarPeriodo(CANTIDAD,{'from':accounts[0],'value':CANTIDAD2})
        
    with brownie.reverts("Cliente"):
        fondoInversion_contract.consultar({'from':accounts[0]})
        
    with brownie.reverts("Banco"):
        fondoInversion_contract.capital_actual(CANTIDAD,{'from':accounts[1]})
        
    with brownie.reverts("Cliente"):
        fondoInversion_contract.recuperaria({'from':accounts[0]})
        
    with brownie.reverts("Cliente"):
        fondoInversion_contract.sacar({'from':accounts[0]})
        
    with brownie.reverts("Recuperar"):
        fondoInversion_contract.devolver({'from':accounts[0],'value':(CANTIDAD*RENTABILIDAD)/100})
    
    fondoInversion_contract.sacar({'from':accounts[1]})
    
    with brownie.reverts("Banco"):
        fondoInversion_contract.devolver({'from':accounts[5],'value':(CANTIDAD*RENTABILIDAD)/100})
    
    with brownie.reverts("Cantidad exacta"):
        fondoInversion_contract.devolver({'from':accounts[0],'value':CANTIDAD})
    
    
