#!/usr/bin/env python3
"""Implementación de referencia independiente (Python) de los modelos de
simulación. Las cifras de las pruebas de Dart se calibraron con este script."""
import math

def ohm(v, r): return v / r, v * v / r
def pot(vin, rpot, a, rl):
    if a <= 0: return 0.0
    up = (1 - a) * rpot; lo = a * rpot * rl / (a * rpot + rl)
    return vin * lo / (up + lo)
def ripple(i, c, full): return i / ((120 if full else 60) * c)
IS, VT = 1e-14, 0.025852
def diode(vs, r):
    lo, hi = 0.0, vs
    for _ in range(200):
        m = (lo + hi) / 2
        if (vs - m) / r - IS * (math.exp(m / VT) - 1) > 0: lo = m
        else: hi = m
    vd = (lo + hi) / 2
    return vd, (vs - vd) / r
def zener(vin, rs, rl, vz=5.1):
    op = vin * rl / (rs + rl)
    vout = min(op, vz)
    i_s = (vin - vout) / rs; il = vout / rl
    return vout, i_s, il, (i_s - il) if op >= vz else 0.0
def bjt(vin, rb, rc, vcc, beta):
    if vin <= 0.7: return 'corte', 0, 0, vcc
    ib = (vin - 0.7) / rb; ica = beta * ib; ics = (vcc - 0.2) / rc
    if ica >= ics: return 'sat', ib, ics, 0.2
    return 'activa', ib, ica, vcc - ica * rc
def mosfet(vgs, vth, vdd, rl, k=1.0):
    if vgs <= vth: return 'corte', 0.0
    isat = k / 2 * (vgs - vth) ** 2
    rds = 0.05 * (10 - vth) / (vgs - vth)
    iohm = vdd / (rl + rds)
    return ('sat', isat) if isat < iohm else ('ohm', iohm, iohm * rds)
def f555(r1, r2, c):
    th = 0.693 * (r1 + r2) * c; tl = 0.693 * r2 * c
    return 1 / (th + tl), th / (th + tl) * 100
def ldr(lux, rf, vcc):
    r = 10000 * (lux / 10) ** -0.7
    return r, vcc * rf / (r + rf)
def ntc(t, b, rf, vcc=5):
    r = 10000 * math.exp(b * (1 / (t + 273.15) - 1 / 298.15))
    return r, vcc * rf / (r + rf)
def echo(d_cm, t):
    c = 331.3 + 0.606 * t
    e = 2 * d_cm / 100 / c
    return c, e, e * 343 / 2 * 100

if __name__ == '__main__':
    print('ohm 12V 470', ohm(12, 470))
    print('pot', pot(5, 10000, 0.5, 1000), pot(5, 10000, 0.5, 1e6))
    print('ripple', ripple(0.5, 2200e-6, True), ripple(0.5, 1000e-6, False))
    print('rc tau', 10000 * 100e-6, 5 * (1 - math.exp(-1)))
    print('rl', 0.1 / 10, 12 / 10 * (1 - math.exp(-1)))
    print('diode 5V 1k', diode(5, 1000))
    print('zener', zener(12, 220, 1000), zener(12, 220, 100), zener(20, 50, 10000))
    print('led', (5 - 2) / 0.015, (12 - 3.2) / 0.02)
    print('bjt', bjt(5, 10000, 1000, 12, 100), bjt(5, 1e6, 1000, 12, 100), bjt(0.5, 10000, 1000, 12, 100))
    print('mosfet', mosfet(3.3, 2, 12, 12), mosfet(5, 2, 12, 12), mosfet(1, 2, 12, 12))
    print('555', f555(10000, 68000, 10e-6), f555(1000, 10000, 10e-6))
    print('opamp', 1 + 10000 / 1000, 11 * 0.5, 11 * 0.37, -10 * 0.5)
    print('7805', (12 - 5) * 0.5, 25 + 3.5 * 65, (6 - 4) * 0.1)
    print('ldr', ldr(10, 10000, 5), ldr(100, 10000, 5))
    print('ntc', ntc(25, 3950, 10000), ntc(0, 3950, 10000), ntc(100, 3950, 10000))
    print('lm35', 0.37, round(0.25 / 5 * 1023), 5 / 1023 / 0.01)
    print('echo', echo(50, 20), echo(100, 35))
