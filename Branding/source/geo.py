import math
def f(v):
    s = '%.2f' % v
    s = s.rstrip('0').rstrip('.')
    return '0' if s in ('-0', '') else s

class T:
    """Affine placement: scale s, then translate."""
    def __init__(s_, s=1, tx=0, ty=0): s_.s, s_.tx, s_.ty = s, tx, ty
    def p(s_, x, y): return f"{f(x*s_.s+s_.tx)} {f(y*s_.s+s_.ty)}"
    def r(s_, v): return f(v*s_.s)

# ---------- symbol: page + plus (mark units) ----------
STD   = dict(x0=44, y0=52, x1=188, y1=236, R=24, cx=184, cy=56, L=36, r=17, g=15)
SMALL = dict(x0=44, y0=52, x1=188, y1=236, R=24, cx=184, cy=56, L=36, r=20, g=21)

def mark_bbox(m):
    return (m['x0'], m['cy']-m['L']-m['r'], m['cx']+m['L']+m['r'], m['y1'])

def page_path(m, t):
    x0,y0,x1,y1,R,cx,cy,L,r,g = (m[k] for k in 'x0 y0 x1 y1 R cx cy L r g'.split())
    ro = r+g; lcx = cx-L; bcy = cy+L
    ax = lcx - math.sqrt(ro*ro-(y0-cy)**2)
    by = bcy + math.sqrt(ro*ro-(x1-cx)**2)
    A = lambda rad, x, y, sw=1: f"A{t.r(rad)} {t.r(rad)} 0 0 {sw} {t.p(x,y)}"
    return (f"M{t.p(x0+R,y0)}L{t.p(ax,y0)}{A(ro,lcx,cy+ro,0)}L{t.p(cx-ro,cy+ro)}L{t.p(cx-ro,bcy)}"
            f"{A(ro,x1,by,0)}L{t.p(x1,y1-R)}{A(R,x1-R,y1)}L{t.p(x0+R,y1)}{A(R,x0,y1-R)}"
            f"L{t.p(x0,y0+R)}{A(R,x0+R,y0)}Z")

def plus_path(m, t):
    cx,cy,L,r = m['cx'],m['cy'],m['L'],m['r']
    A = lambda x, y: f"A{t.r(r)} {t.r(r)} 0 0 0 {t.p(x,y)}"
    return (f"M{t.p(cx+r,cy-r)}L{t.p(cx+r,cy-L)}{A(cx-r,cy-L)}L{t.p(cx-r,cy-r)}L{t.p(cx-L,cy-r)}"
            f"{A(cx-L,cy+r)}L{t.p(cx-r,cy+r)}L{t.p(cx-r,cy+L)}{A(cx+r,cy+L)}L{t.p(cx+r,cy+r)}"
            f"L{t.p(cx+L,cy+r)}{A(cx+L,cy-r)}Z")

def fit(bbox, box, opt=0.0):
    """Place bbox centred in box=(x,y,w,h), scaled to fit; opt nudges up by opt*h."""
    bx0,by0,bx1,by1 = bbox; x,y,w,h = box
    s = min(w/(bx1-bx0), h/(by1-by0))
    return T(s, x + (w-(bx1-bx0)*s)/2 - bx0*s, y + (h-(by1-by0)*s)/2 - by0*s - opt*h)

# ---------- wordmark "snapdoc": monoline, round terminals like the plus ----------
W = 25.0; HW = W/2; BR = 45.0; BY = -56.0     # stroke, bowl centre-line radius, bowl centre y
XT, BL, AS, DS = -101.0, -11.0, -149.0, 37.0  # centre-line heights: x-height, baseline, ascender, descender

def stadium(t, x0, y0, x1, y1):
    dx, dy = x1-x0, y1-y0; n = math.hypot(dx, dy); nx, ny = -dy/n*HW, dx/n*HW
    return (f"M{t.p(x0+nx,y0+ny)}L{t.p(x1+nx,y1+ny)}A{t.r(HW)} {t.r(HW)} 0 0 0 {t.p(x1-nx,y1-ny)}"
            f"L{t.p(x0-nx,y0-ny)}A{t.r(HW)} {t.r(HW)} 0 0 0 {t.p(x0+nx,y0+ny)}Z")

def ring(t, cx, cy, R=BR):
    o, i = R+HW, R-HW
    return (f"M{t.p(cx-o,cy)}A{t.r(o)} {t.r(o)} 0 1 1 {t.p(cx+o,cy)}A{t.r(o)} {t.r(o)} 0 1 1 {t.p(cx-o,cy)}Z"
            f"M{t.p(cx-i,cy)}A{t.r(i)} {t.r(i)} 0 1 0 {t.p(cx+i,cy)}A{t.r(i)} {t.r(i)} 0 1 0 {t.p(cx-i,cy)}Z")

def arcstroke(t, cx, cy, R, a0, a1):
    """Stroke along a circle from angle a0 to a1 (degrees, a1>a0, clockwise on screen), round caps."""
    o, i = R+HW, R-HW
    P = lambda rad, a: (cx+rad*math.cos(math.radians(a)), cy+rad*math.sin(math.radians(a)))
    lg = 1 if a1-a0 > 180 else 0
    return (f"M{t.p(*P(o,a0))}A{t.r(o)} {t.r(o)} 0 {lg} 1 {t.p(*P(o,a1))}"
            f"A{t.r(HW)} {t.r(HW)} 0 0 1 {t.p(*P(i,a1))}A{t.r(i)} {t.r(i)} 0 {lg} 0 {t.p(*P(i,a0))}"
            f"A{t.r(HW)} {t.r(HW)} 0 0 1 {t.p(*P(o,a0))}Z")

SR = 24.5  # s bowl radius
def glyphs():
    """Return (list of (kind, args)), advance-width) per letter, x relative to the letter's left outer edge."""
    G = {}
    # s: upper arc (counter-clockwise from upper-right terminal to spine), spine, lower arc
    sp = 14.0; uy = (XT+(XT+BL)/2)/2; ly = (BL+(XT+BL)/2)/2; sr = (BL-XT)/4
    ux = HW+sr; lx = ux+sp
    G['s'] = ([('arc', (ux, uy, sr, 90, 318)),            # spine -> left -> over the top -> upper-right terminal
               ('line', (ux, (XT+BL)/2, lx, (XT+BL)/2)),
               ('arc', (lx, ly, sr, -90, 138))], lx+sr+HW)
    G['n'] = ([('line', (HW, XT, HW, BL)), ('arc', (HW+BR, BY, BR, 180, 360)),
               ('line', (HW+2*BR, BY, HW+2*BR, BL))], 2*BR+W)
    G['a'] = ([('ring', (HW+BR, BY)), ('line', (HW+2*BR, XT, HW+2*BR, BL))], 2*BR+W)
    G['p'] = ([('ring', (HW+BR, BY)), ('line', (HW, XT, HW, DS))], 2*BR+W)
    G['d'] = ([('ring', (HW+BR, BY)), ('line', (HW+2*BR, AS, HW+2*BR, BL))], 2*BR+W)
    G['o'] = ([('ring', (HW+BR, BY))], 2*BR+W)
    G['c'] = ([('arc', (HW+BR, BY, BR, 42, 318))], 2*BR+W - 6)
    return G

# spacing between outer edges (units)
GAP = {('s','n'):18, ('n','a'):18, ('a','p'):22, ('p','d'):16, ('d','o'):20, ('o','c'):14}
WORD = 'snapdoc'

def word_layout():
    G = glyphs(); x = 0; out = []
    for i, ch in enumerate(WORD):
        out.append((ch, x)); x += G[ch][1]
        if i+1 < len(WORD): x += GAP[(ch, WORD[i+1])]
    return out, x   # total width

def word_paths(t):
    G = glyphs(); lay, _ = word_layout(); rings, strokes = [], []  # each entry becomes its own <path>
    for ch, x in lay:
        for kind, a in G[ch][0]:
            if kind == 'ring': rings.append(ring(t, x+a[0], a[1]))
            elif kind == 'line': strokes.append(stadium(t, x+a[0], a[1], x+a[2], a[3]))
            else: strokes.append(arcstroke(t, x+a[0], a[1], a[2], a[3], a[4]))
    return rings, strokes

def word_bbox():
    _, w = word_layout(); return (0, AS-HW, w, DS+HW)
