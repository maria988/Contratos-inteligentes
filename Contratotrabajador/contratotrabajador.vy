# @version ^0.2.8
#Contrato trabajador, te despiden si no cumples con las horas establecidas

#variables de la empresa 
empresa: public(address)
salario: public(uint256)
despedido: bool
#precio por hora trabajada
precio_hora: public(uint256)
#Se acumula la posible indemnizacion
indemnizacion: uint256
#El precio de la indemnizacion cada mes
mes_indem: public(uint256)

#Variables referidas al contrato
duracion_contrato: public(uint256)
horas_mes:public(uint256)
fin_de_mes: public(uint256)

#Variable referidas al trabajador
trabajador: public(address)
hora_entrada: uint256
horas_acumuladas: uint256
trabaja: bool

#Inicializacion del contrato
@external 
def __init__(_duracion_contrato: uint256, _trabajador: address, _horas_mes: uint256,_salario:uint256,_fin_de_mes: uint256,_precio_hora:uint256,_mes_indem:uint256):
    assert _salario > 0
    assert _horas_mes > 0
    assert _duracion_contrato > 0
    assert _mes_indem > 0
    self.empresa = msg.sender
    self.trabajador = _trabajador
    self.horas_mes = _horas_mes
    self.salario = _salario
    self.duracion_contrato = _duracion_contrato
    self.fin_de_mes = block.timestamp + _fin_de_mes
    self.hora_entrada = 0
    self.horas_acumuladas = 0
    self.precio_hora = _precio_hora
    self.mes_indem = _mes_indem
    self.indemnizacion = 0

#El trabajador llama a esta funcion para confirmar que va a trabajar
@external
def firmar():
    assert self.trabajador == msg.sender,"Es el trabajador"
    self.trabaja = True

#El trabajador llama a esta funcion al empezar y al terminar,
#Se registra cuando entre y se acumula cuando sale
@external
def fichar():
    assert msg.sender == self.trabajador,"Es el trabajador"
    assert block.timestamp <= self.fin_de_mes,"No se ha terminado el mes"
    if self.hora_entrada == 0:
        self.hora_entrada = block.timestamp
    else:
        self.horas_acumuladas = block.timestamp - self.hora_entrada
        self.hora_entrada = 0

#Funcion para dejar de trabajar
@external
def dejareltrabajo():
    assert msg.sender == self.trabajador,"El trabajador"
    self.trabaja = False

#Funcion para despedir al trabajador   
@external
def despedir():
    assert msg.sender == self.empresa,"La empresa"
    self.despedido = True

#Funcion para pagar al trabajador
@payable
@external
def pagar():
    assert msg.sender == self.empresa,"La empresa"
    assert (block.timestamp >= self.fin_de_mes) or (not self.trabaja),"Se ha terminado el mes"
    assert (msg.value == (self.precio_hora * self.horas_acumuladas)+self.mes_indem),"Valor del sueldo"
    if self.despedido:
        send(self.trabajador, self.salario + self.indemnizacion)
        selfdestruct(self.empresa)
    else:
        send(self.trabajador,msg.value-self.mes_indem)
        self.indemnizacion += self.mes_indem
        self.horas_acumuladas = 0
        if self.horas_acumuladas < self.horas_mes:
            self.despedido = True
            selfdestruct(self.empresa)
        elif block.timestamp > self.duracion_contrato :
            selfdestruct(self.empresa)
