// kit.js — the drawing kit for "The factory" (public version).
// Signature: thick ink outline, flat fills, a hard offset ink shadow, screentone dots.
// The rule that carries the idea: ROUND characters are models (they read and judge);
// SQUARE robots and boxes are code (they cut, check, count and certify). Everything is a pure function of time t (seconds).
// Palette: the same cool neutrals as "Open the box", ONE accent (violet). Full violet means one thing only:
// certified by code (the PASS stamp and the packets that went through it). The pale tint marks "now".
(function(){
const INK='#15171C', PAPER='#FFFFFF', GROUND='#F1F2F4', PALE='#E7E9ED', GREY='#D3D7DD', MID='#8C929C',
      ACC='#6A4CF5', ACC_L='#DCD4FF', WOOD='#A97C4F';
const r2=v=>Math.round(v*10)/10;
const SANS='-apple-system,BlinkMacSystemFont,Segoe UI,system-ui,sans-serif', MONO='ui-monospace,SF Mono,Menlo,Consolas,monospace';

const CSS=`
:root{--sans:-apple-system,BlinkMacSystemFont,"Segoe UI",system-ui,Roboto,sans-serif;
  --mono:ui-monospace,"SF Mono",SFMono-Regular,Menlo,Consolas,monospace;
  --ink:${INK};--ink2:#3D424C;--ink3:#5F6672;--ink4:#8C929C;--ground:${GROUND};--pale:${PALE};--acc:${ACC};--acc-l:${ACC_L}}
#stage{position:relative;width:1280px;height:720px;overflow:hidden;font-variant-numeric:tabular-nums;background:var(--ground);font-family:var(--sans);color:var(--ink)}
.abs{position:absolute}
.tone{background-image:radial-gradient(rgba(21,23,28,.11) 1.1px,transparent 1.3px);background-size:7px 7px}
.tone-acc{background-color:${ACC_L};background-image:radial-gradient(rgba(21,23,28,.14) 1.2px,transparent 1.4px);background-size:6px 6px}
.ink{border:2.5px solid var(--ink);border-radius:10px;background:#fff;box-shadow:4px 4px 0 var(--ink)}
.badge{left:34px;top:24px;width:96px;height:96px;border:3px solid var(--ink);border-radius:16px;box-shadow:5px 5px 0 var(--ink);
  display:flex;align-items:center;justify-content:center;font-size:70px;font-weight:900;line-height:1;transform:rotate(-4deg)}
.kicker{left:156px;top:26px;font-size:14px;font-weight:700;color:var(--ink3);letter-spacing:.05em}
.head{left:156px;top:48px;margin:0;font-size:32px;font-weight:850;line-height:1.12;letter-spacing:-.015em}
.head b{background:linear-gradient(transparent 60%, var(--acc-l) 60%);font-weight:900}
.rule{right:34px;top:30px;width:330px;padding:9px 14px;font-size:14px;line-height:1.35;transform:rotate(1.2deg)}
.rule .k{font-size:11px;font-weight:800;letter-spacing:.06em;color:var(--ink3)}
.bub{position:absolute;background:#fff;border:2.5px solid var(--ink);border-radius:16px;padding:9px 13px;font-size:14.5px;line-height:1.35;box-shadow:3px 3px 0 var(--ink)}
`;
function injectCSS(){const s=document.createElement('style');s.textContent=CSS;document.head.prepend(s);}

// Scale the 1280x720 stage to the viewport and size its frame, so the text version flows below it.
function fit(W=1280,H=720){const fr=document.getElementById('frame');
  const f=()=>{const w=document.documentElement.clientWidth||innerWidth;const s=Math.min(w/W,innerHeight/H);
    document.getElementById('fit').style.transform=`scale(${s})`; if(fr){fr.style.width=(W*s)+'px';fr.style.height=(H*s)+'px';}};
  addEventListener('resize',f);f();}
function run(render,L){const q=new URLSearchParams(location.search);
  if(q.has('t')) render(parseFloat(q.get('t')));
  else {const t0=performance.now();(function loop(){render(((performance.now()-t0)/1000)%L);requestAnimationFrame(loop);})();}}

// a packet: a little folded sheet of notes
function packet(x,y,s=1,fill=PAPER,rot=0){
  return `<g transform="translate(${r2(x)},${r2(y)}) rotate(${r2(rot)}) scale(${s})">
   <rect x="-9" y="-7" width="18" height="14" rx="2" fill="${fill}" stroke="${INK}" stroke-width="2"/>
   <path d="M-9,-7 L0,1 L9,-7" fill="none" stroke="${INK}" stroke-width="1.6"/></g>`;
}
// a round worker (a model). hat letter S = Sonnet, O = Opus. pose: read | idle | cheer
function worker(x,y,t,o={}){
  const s=o.s||1, hat=o.hat||'S', pose=o.pose||'idle', ph=o.ph||0;
  const bob = pose==='read'? Math.sin(t*5+ph)*1.6 : Math.sin(t*2+ph)*0.8;
  const look = pose==='read'? Math.sin(t*2.2+ph)*2.2 : 0;
  const blink = ((t*0.7+ph)%3)<0.08;
  const cheer = pose==='cheer';
  let arms='';
  if(pose==='read'){ arms=`<path d="M-13,6 q-4,10 4,15 M13,6 q4,10 -4,15" stroke="${INK}" stroke-width="2.4" fill="none" stroke-linecap="round"/>`+
     `<g transform="translate(0,${r2(21+Math.sin(t*5+ph))})"><rect x="-11" y="-8" width="22" height="15" rx="2" fill="#fff" stroke="${INK}" stroke-width="2"/>
      <path d="M-6,-3 h12 M-6,1 h9" stroke="${INK}" stroke-width="1.3"/></g>`; }
  else if(cheer){ arms=`<path d="M-13,2 l-9,-14 M13,2 l9,-14" stroke="${INK}" stroke-width="2.6" stroke-linecap="round"/>`; }
  else { arms=`<path d="M-13,5 q-6,6 -3,12 M13,5 q6,6 3,12" stroke="${INK}" stroke-width="2.4" fill="none" stroke-linecap="round"/>`; }
  const eyes = blink? `<path d="M${r2(-6+look)},-6 h4 M${r2(2+look)},-6 h4" stroke="${INK}" stroke-width="2"/>`
                    : `<circle cx="${r2(-4+look)}" cy="-6" r="2.3" fill="${INK}"/><circle cx="${r2(4+look)}" cy="-6" r="2.3" fill="${INK}"/>`;
  const mouth = cheer? `<path d="M-4,0 q4,5 8,0" fill="${MID}" stroke="${INK}" stroke-width="1.6"/>` : pose==='read'? `<circle cx="${r2(look*0.5)}" cy="1" r="1.6" fill="${INK}"/>` : `<path d="M-3,0 q3,3 6,0" fill="none" stroke="${INK}" stroke-width="1.6"/>`;
  return `<g transform="translate(${r2(x)},${r2(y)}) scale(${s})">
   <ellipse cx="0" cy="34" rx="15" ry="4" fill="rgba(21,23,28,.15)"/>
   <path d="M-6,22 l-2,12 M6,22 l2,12" stroke="${INK}" stroke-width="3" stroke-linecap="round"/>
   <g transform="translate(0,${r2(bob)})">
    <ellipse cx="0" cy="6" rx="17" ry="18" fill="#fff" stroke="${INK}" stroke-width="2.6"/>
    ${eyes}${mouth}
    <path d="M-16,-6 a16,15 0 0 1 32,0 z" fill="${INK}" stroke="${INK}" stroke-width="2.4"/>
    <rect x="-19" y="-8" width="38" height="5" rx="2.5" fill="${INK}" stroke="${INK}" stroke-width="2.2"/>
    <text x="0" y="-11" text-anchor="middle" font-size="10" font-weight="900" fill="#fff" font-family="${SANS}">${hat}</text>
    ${arms}
   </g></g>`;
}
// the judge: a bigger round worker in a robe, with a gavel. hit in [0,1]: 1 = gavel down
function judge(x,y,t,o={}){
  const s=o.s||1, hit=o.hit||0, ang=15+85*hit;
  return `<g transform="translate(${r2(x)},${r2(y)}) scale(${s})">
   <ellipse cx="0" cy="40" rx="22" ry="5" fill="rgba(21,23,28,.15)"/>
   <path d="M-20,8 q0,30 20,32 q20,-2 20,-32 z" fill="${INK}"/>
   <path d="M-6,10 l6,8 l6,-8" fill="#fff" stroke="#fff" stroke-width="1"/>
   <ellipse cx="0" cy="-4" rx="18" ry="17" fill="#fff" stroke="${INK}" stroke-width="2.6"/>
   <circle cx="-5" cy="-6" r="2.4" fill="${INK}"/><circle cx="5" cy="-6" r="2.4" fill="${INK}"/>
   <path d="M-6,-13 l5,2 M6,-13 l-5,2" stroke="${INK}" stroke-width="2" stroke-linecap="round"/>
   <path d="M-4,2 h8" stroke="${INK}" stroke-width="2" stroke-linecap="round"/>
   <path d="M-17,-15 a17,15 0 0 1 34,0 z" fill="${INK}" stroke="${INK}" stroke-width="2.4"/>
   <rect x="-20" y="-17" width="40" height="5" rx="2.5" fill="${INK}" stroke="${INK}" stroke-width="2.2"/>
   <text x="0" y="-20" text-anchor="middle" font-size="10" font-weight="900" fill="#fff" font-family="${SANS}">O</text>
   <g transform="translate(18,10) rotate(${r2(ang)})">
     <rect x="-2" y="-30" width="4" height="30" rx="2" fill="${WOOD}" stroke="${INK}" stroke-width="1.8"/>
     <rect x="-11" y="-40" width="22" height="12" rx="3" fill="${WOOD}" stroke="${INK}" stroke-width="2.2"/>
   </g></g>`;
}
// a square robot (code). The foreman wears a headband. walk = legs move
function bot(x,y,t,o={}){
  const s=o.s||1, walk=o.walk||0, band=o.band!==false;
  const step = walk? Math.sin(t*10)*4 : 0, bob = walk? Math.abs(Math.sin(t*10))*-2.5 : Math.sin(t*2)*0.6;
  const tail = Math.sin(t*7)*4, blink = (t%2.7)<0.1;
  const faceSvg = (blink? `<path d="M-8,-20 h5 M3,-20 h5" stroke="#fff" stroke-width="2.4"/>` : `<rect x="-8" y="-23" width="5" height="6" rx="1" fill="#fff"/><rect x="3" y="-23" width="5" height="6" rx="1" fill="#fff"/>`)+`<path d="M-4,-12 h8" stroke="#fff" stroke-width="2"/>`;
  return `<g transform="translate(${r2(x)},${r2(y)}) scale(${s})">
   <ellipse cx="0" cy="34" rx="18" ry="4" fill="rgba(21,23,28,.15)"/>
   <path d="M-7,20 l${r2(-step*0.5)},14 M7,20 l${r2(step*0.5)},14" stroke="${INK}" stroke-width="3.2" stroke-linecap="square"/>
   <g transform="translate(0,${r2(bob)})">
    <line x1="0" y1="-36" x2="0" y2="-44" stroke="${INK}" stroke-width="2.4"/><circle cx="0" cy="-46" r="3.2" fill="#fff" stroke="${INK}" stroke-width="2"/>
    <rect x="-16" y="-36" width="32" height="30" rx="4" fill="#fff" stroke="${INK}" stroke-width="2.6"/>
    <rect x="-12" y="-30" width="24" height="20" rx="2" fill="${INK}"/>
    ${faceSvg}
    ${band? `<rect x="-17" y="-38" width="34" height="6" fill="${INK}" stroke="${INK}" stroke-width="2"/>
      <path d="M17,-36 l9,${r2(-3+tail*0.3)} M17,-34 l8,${r2(4+tail*0.4)}" stroke="${INK}" stroke-width="3" stroke-linecap="round"/>`:''}
    <rect x="-14" y="-4" width="28" height="25" rx="3" fill="#fff" stroke="${INK}" stroke-width="2.6"/>
    <rect x="-7" y="2" width="14" height="9" rx="1.5" fill="${GREY}" stroke="${INK}" stroke-width="1.6"/>
    <path d="M-14,2 l-8,${r2(8+step*0.3)} M14,2 l8,${r2(8-step*0.3)}" stroke="${INK}" stroke-width="3" stroke-linecap="square"/>
   </g></g>`;
}
// a machine: a square box (code) with a digit window
function machine(x,y,w,h,o={}){
  const digits=o.digits, title=o.title||'', shake=o.shake||0, dx = shake? Math.sin(shake*60)*1.2 : 0;
  return `<g transform="translate(${r2(x+dx)},${r2(y)})">
   <rect x="4" y="4" width="${w}" height="${h}" rx="6" fill="${INK}"/>
   <rect x="0" y="0" width="${w}" height="${h}" rx="6" fill="#fff" stroke="${INK}" stroke-width="2.6"/>
   <circle cx="10" cy="10" r="3" fill="${GREY}" stroke="${INK}" stroke-width="1.5"/><circle cx="20" cy="10" r="3" fill="#fff" stroke="${INK}" stroke-width="1.5"/>
   ${title?`<text x="${w-8}" y="14" text-anchor="end" font-size="10" font-weight="800" fill="${INK}" font-family="${MONO}">${title}</text>`:''}
   ${digits!==undefined?`<rect x="8" y="${h-30}" width="${w-16}" height="22" rx="3" fill="${INK}"/>
     <text x="${w/2}" y="${h-14}" text-anchor="middle" font-size="15" font-weight="800" fill="#fff" font-family="${MONO}">${digits}</text>`:''}
  </g>`;
}
// the gate: a square robot arm that slams a stamp. hit in [0,1]
function stamper(x,y,t,o={}){
  const hit=o.hit||0, s=o.s||1, word=o.word||'PASS', off=-26*(1-hit);
  return `<g transform="translate(${r2(x)},${r2(y)}) scale(${s})">
   <rect x="-26" y="-74" width="52" height="40" rx="5" fill="#fff" stroke="${INK}" stroke-width="2.6"/>
   <rect x="-20" y="-68" width="40" height="22" rx="2" fill="${INK}"/>
   <rect x="-13" y="-63" width="6" height="7" fill="#fff"/><rect x="7" y="-63" width="6" height="7" fill="#fff"/>
   <rect x="-27" y="-77" width="54" height="6" fill="${INK}" stroke="${INK}" stroke-width="2"/>
   <rect x="-5" y="-34" width="10" height="${r2(Math.max(2,26+off))}" fill="${GREY}" stroke="${INK}" stroke-width="2"/>
   <g transform="translate(0,${r2(off)})">
     <rect x="-20" y="-8" width="40" height="14" rx="3" fill="${INK}" stroke="${INK}" stroke-width="2.4"/>
     <text x="0" y="3.5" text-anchor="middle" font-size="10" font-weight="900" fill="#fff" font-family="${SANS}">${word}</text>
   </g></g>`;
}
function sfxSvg(text,x,y,rot=-8,size=22,fill=INK){
  return `<text x="${r2(x)}" y="${r2(y)}" transform="rotate(${rot} ${r2(x)} ${r2(y)})" text-anchor="middle" font-size="${size}" font-weight="900" font-style="italic"
    fill="${fill}" stroke="#fff" stroke-width="5" paint-order="stroke" font-family="${SANS}">${text}</text>`;
}
const ease=p=>p<.5?2*p*p:1-Math.pow(-2*p+2,2)/2;
const clamp=(v,a,b)=>Math.max(a,Math.min(b,v));

window.KIT={INK,PAPER,GROUND,PALE,GREY,MID,ACC,ACC_L,WOOD,SANS,MONO,injectCSS,fit,run,packet,worker,judge,bot,machine,stamper,sfxSvg,ease,clamp};
})();
