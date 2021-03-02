
import pytest

import brownie
import time

DURACION_CONTRATO = 10
HORAS_MES = 1
SALARIO = 20
FIN_DE_MES = 5
PRECIO_HORA = 20
MES_INDEM = 10


@pytest.fixture
def trabajador_contract(contratotrabajador, accounts):
    yield contratotrabajador.deploy(DURACION_CONTRATO,accounts[1],HORAS_MES,SALARIO,FIN_DE_MES,PRECIO_HORA,MES_INDEM,{'from': accounts[0]})

def test_inicial(trabajador_contract,accounts):
    assert trabajador_contract.empresa() == accounts[0]
    assert trabajador_contract.trabajador() == accounts[1]
    assert trabajador_contract.horas_mes() == HORAS_MES
    assert trabajador_contract.salario() == SALARIO
    assert trabajador_contract.precio_hora() == PRECIO_HORA
    assert trabajador_contract.mes_indem() == MES_INDEM
    assert trabajador_contract.duracion_mes() == FIN_DE_MES
    
    
def test_uso(trabajador_contract,accounts):
    trabajador_contract.firmar({'from':accounts[1]})
    assert trabajador_contract.trabaja()
    trabajador_contract.fichar({'from':accounts[1]})
    time.sleep(1)
    trabajador_contract.fichar({'from':accounts[1]})
    time.sleep(5)
    trabajador_contract.pagar({'from':accounts[0],'value':trabajador_contract.horas_acumuladas()*PRECIO_HORA+MES_INDEM})
    assert not trabajador_contract.despedido()
    trabajador_contract.fichar({'from':accounts[1]})
    time.sleep(2)
    trabajador_contract.fichar({'from':accounts[1]})
    trabajador_contract.dejareltrabajo({'from':accounts[1]})
    assert not trabajador_contract.trabaja()
    assert trabajador_contract.indemnizacion () == 10
    trabajador_contract.pagar({'from':accounts[0],'value':trabajador_contract.horas_acumuladas()*PRECIO_HORA+MES_INDEM})
    
def test_failed_transactions(trabajador_contract, accounts):
    
    with brownie.reverts("Es el trabajador"):
        trabajador_contract.firmar({'from': accounts[2]})
    
    trabajador_contract.firmar({'from': accounts[1]})
    
    with brownie.reverts("Es el trabajador"):
        trabajador_contract.fichar({'from': accounts[2]})
        
    with brownie.reverts("El trabajador"):
        trabajador_contract.dejareltrabajo({'from': accounts[2]})
        
    with brownie.reverts("La empresa"):
        trabajador_contract.despedir({'from': accounts[2]})
    
    with brownie.reverts("La empresa"):
        trabajador_contract.pagar({'from': accounts[2],'value':100})
        
    with brownie.reverts("Se ha terminado el mes"):
        trabajador_contract.pagar({'from': accounts[0],'value':100})
        
    trabajador_contract.despedir({'from': accounts[0]})
    
    with brownie.reverts("No despedido y trabaja"):
        trabajador_contract.fichar({'from': accounts[1]})
    time.sleep(10)
    
    with brownie.reverts("No se ha terminado el mes"):
        trabajador_contract.fichar({'from': accounts[1]})
        
    with brownie.reverts("Valor del sueldo"):
        trabajador_contract.pagar({'from': accounts[0],'value':0})
