import sys; sys.path.insert(0,'.')
from geo import *
INK, ACC, WHITE = '#16181D', '#F25A2B', '#FFFFFF'
def svgdoc(w, h, body, title='SnapDoc'):
    return f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {f(w)} {f(h)}"><title>{title}</title>{body}</svg>\n'
def sym(m, t, page, plus):
    return f'<path fill="{page}" d="{page_path(m,t)}"/><path fill="{plus}" d="{plus_path(m,t)}"/>'
def word(t, col):
    rg, st = word_paths(t)
    return (''.join(f'<path fill="{col}" fill-rule="evenodd" d="{d}"/>' for d in rg)
            + ''.join(f'<path fill="{col}" d="{d}"/>' for d in st))

def symbol_files(m, suffix=''):
    t = fit(mark_bbox(m), (16, 16, 224, 224), opt=0.0)
    out = {}
    for name, pg, pl in [('', INK, ACC), ('-reversed', WHITE, ACC), ('-black', '#000', '#000'), ('-white', WHITE, WHITE)]:
        out[f'snapdoc-symbol{suffix}{name}.svg'] = svgdoc(256, 256, sym(m, t, pg, pl))
    return out

def lockups():
    out = {}
    mb = mark_bbox(STD); wb = word_bbox()
    # horizontal: symbol height H=256; wordmark x-height = 0.40 H, x-height band centred on the page body
    H = 256; ts = H/(mb[3]-mb[1]); tsym = T(ts, -mb[0]*ts, -mb[1]*ts)
    ws = (0.40*H)/(-XT+HW - 0)    # x-height outer = 112 units
    page_mid = ((STD['y0']+STD['y1'])/2 - mb[1])*ts
    gap = 0.20*H
    wx = (mb[2]-mb[0])*ts + gap
    wy = page_mid - (BY)*ws      # x-height centre (BY) on page centre
    tw = T(ws, wx, wy)
    Wd = wx + (wb[2])*ws
    for name, pg, pl, wc in [('', INK, ACC, INK), ('-reversed', WHITE, ACC, WHITE), ('-black', '#000', '#000', '#000'), ('-white', WHITE, WHITE, WHITE)]:
        out[f'snapdoc-horizontal{name}.svg'] = svgdoc(Wd, H, sym(STD, tsym, pg, pl) + word(tw, wc))
    # stacked: symbol on top, wordmark centred under it
    ws2 = ws*0.9; wwid = wb[2]*ws2; symw = (mb[2]-mb[0])*ts
    Wd2 = max(wwid, symw); sx = (Wd2-symw)/2
    tsym2 = T(ts, sx - mb[0]*ts, -mb[1]*ts)
    wy2 = H + 0.16*H + (-(AS-HW))*ws2
    tw2 = T(ws2, (Wd2-wwid)/2, wy2)
    H2 = wy2 + (DS+HW)*ws2
    for name, pg, pl, wc in [('', INK, ACC, INK), ('-reversed', WHITE, ACC, WHITE), ('-black', '#000', '#000', '#000'), ('-white', WHITE, WHITE, WHITE)]:
        out[f'snapdoc-stacked{name}.svg'] = svgdoc(Wd2, H2, sym(STD, tsym2, pg, pl) + word(tw2, wc))
    # wordmark only
    tw3 = T(1, 0, -(AS-HW))
    for name, wc in [('', INK), ('-white', WHITE), ('-black', '#000')]:
        out[f'snapdoc-wordmark{name}.svg'] = svgdoc(wb[2], wb[3]-wb[1], word(tw3, wc))
    return out

def app_icon(m, size=1024, shadow=True, frac=0.6):
    # Apple macOS grid: 824×824 body at 100,100, continuous-corner radius ≈ 185
    body = (f'<defs><linearGradient id="bg" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#2A2E37"/>'
            f'<stop offset="1" stop-color="#121418"/></linearGradient>'
            + ('<filter id="sh" x="-20%" y="-20%" width="140%" height="140%"><feDropShadow dx="0" dy="10" stdDeviation="12" flood-color="#000" flood-opacity=".30"/></filter>' if shadow else '')
            + '</defs>'
            f'<rect x="100" y="100" width="824" height="824" rx="185" fill="url(#bg)"{" filter=\"url(#sh)\"" if shadow else ""}/>'
            '<rect x="101" y="101" width="822" height="822" rx="184" fill="none" stroke="#fff" stroke-opacity=".08" stroke-width="2"/>')
    o = (1-frac)/2; t = fit(mark_bbox(m), (100+824*o, 100+824*(o-0.01), 824*frac, 824*frac), opt=0.0)
    body += sym(m, t, WHITE, ACC)
    return svgdoc(1024, 1024, body, 'SnapDoc app icon')

def menubar():
    # template image: 18×18 pt canvas, mark 16 pt tall, pure black (macOS tints it)
    m = SMALL; t = fit(mark_bbox(m), (0.5*14, 1*14, 17*14, 16*14))   # built at 252 = 18pt×14
    return svgdoc(252, 252, sym(m, t, '#000', '#000'), 'SnapDoc menu bar')

if __name__ == '__main__':
    import os
    out = {}
    out.update(symbol_files(STD)); out.update(symbol_files(SMALL, '-small')); out.update(lockups())
    out['snapdoc-appicon-macos.svg'] = app_icon(STD)
    out['snapdoc-appicon-macos-small.svg'] = app_icon(SMALL, shadow=False, frac=0.7)
    for name, frac in [('snapdoc-tile.svg', 0.62), ('snapdoc-tile-maskable.svg', 0.5)]:
        t = fit(mark_bbox(STD), (512*(1-frac)/2, 512*(1-frac)/2 - 4, 512*frac, 512*frac))
        out[name] = svgdoc(512, 512, f'<rect width="512" height="512" fill="{INK}"/>' + sym(STD, t, WHITE, ACC), 'SnapDoc')
    out['snapdoc-menubar-template.svg'] = menubar()
    os.makedirs('../masters', exist_ok=True)
    for k, v in out.items(): open('../masters/'+k, 'w').write(v)
    print('\n'.join(sorted(out)))
