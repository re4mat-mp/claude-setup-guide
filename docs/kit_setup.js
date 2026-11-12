// kit_setup.js — extra pieces for "Open the box", on top of kit.js (same family, same signature).
// ROUND = models (the agents: they read, build, judge); SQUARE = code (the hooks: they enforce).
// Hat letter = the model in the agent's frontmatter.
(function(){
const {INK,GREY,PALE,MID,ACC,ACC_L,WOOD,worker}=KIT;
const r2=v=>Math.round(v*10)/10;
const F='-apple-system,system-ui,sans-serif', M='ui-monospace,Menlo,monospace';

// a prop held at the right hand of a worker placed at (x,y)
function prop(kind,x,y,t,ph=0){
  const sw=Math.sin(t*6+ph);
  if(kind==='hammer'){ const a=-30+sw*28;
    return `<g transform="translate(${r2(x+20)},${r2(y+12)}) rotate(${r2(a)})">
      <rect x="-2" y="-26" width="4" height="28" rx="2" fill="${WOOD}" stroke="${INK}" stroke-width="1.8"/>
      <rect x="-10" y="-34" width="20" height="11" rx="2" fill="${GREY}" stroke="${INK}" stroke-width="2.2"/></g>`; }
  if(kind==='wrench'){ const a=20+sw*10;
    return `<g transform="translate(${r2(x+21)},${r2(y+14)}) rotate(${r2(a)})">
      <rect x="-2.5" y="-24" width="5" height="24" rx="2" fill="${GREY}" stroke="${INK}" stroke-width="1.8"/>
      <path d="M-7,-24 a7,7 0 1 1 14,0 l-4,0 l0,-5 l-6,0 l0,5 z" fill="${GREY}" stroke="${INK}" stroke-width="1.8"/></g>`; }
  if(kind==='glass'){ const dx=sw*3;
    return `<g transform="translate(${r2(x+24+dx)},${r2(y+2)})">
      <line x1="5" y1="7" x2="12" y2="16" stroke="${INK}" stroke-width="3.4" stroke-linecap="round"/>
      <circle cx="0" cy="0" r="9" fill="${PALE}" fill-opacity=".8" stroke="${INK}" stroke-width="2.6"/></g>`; }
  if(kind==='cards'){ const dy=sw*2;
    return `<g transform="translate(${r2(x+24)},${r2(y+10+dy)}) rotate(8)">
      <rect x="-9" y="-12" width="18" height="22" rx="2" fill="#fff" stroke="${INK}" stroke-width="2"/>
      <rect x="-6" y="-15" width="18" height="22" rx="2" fill="${PALE}" stroke="${INK}" stroke-width="2"/>
      <path d="M-2,-9 h10 M-2,-5 h7" stroke="${INK}" stroke-width="1.3"/>
      <circle cx="3" cy="-14" r="2.4" fill="${INK}"/></g>`; }
  if(kind==='jar'){ return `<g transform="translate(${r2(x+26)},${r2(y+12)})">
      <rect x="-11" y="-14" width="22" height="26" rx="5" fill="#fff" fill-opacity=".8" stroke="${INK}" stroke-width="2.2"/>
      <rect x="-12" y="-18" width="24" height="6" rx="2" fill="${MID}" stroke="${INK}" stroke-width="2"/>
      ${bug(-4,-2+sw*1.5,0.42,t)}${bug(4,5-sw*1.5,0.42,t+1)}${bug(-3,8,0.38,t+2)}</g>`; }
  return '';
}
// an agent: a worker with a hat letter and a craft prop
function agent(x,y,t,o={}){ return worker(x,y,t,{hat:o.hat||'O',pose:o.pose||'idle',ph:o.ph||0,s:o.s||1}) + (o.prop?prop(o.prop,x,y,t,o.ph||0):''); }

// a mutant: a tiny bug
function bug(x,y,s=1,t=0){ const w=Math.sin(t*14)*2;
  return `<g transform="translate(${r2(x)},${r2(y)}) scale(${s})">
    <path d="M-9,-4 l-5,${r2(-3+w*0.5)} M-9,2 l-6,1 M-8,7 l-5,${r2(4-w*0.5)} M9,-4 l5,${r2(-3-w*0.5)} M9,2 l6,1 M8,7 l5,${r2(4+w*0.5)}" stroke="${INK}" stroke-width="2" stroke-linecap="round"/>
    <ellipse cx="0" cy="2" rx="10" ry="9" fill="${MID}" stroke="${INK}" stroke-width="2.2"/>
    <circle cx="0" cy="-8" r="5" fill="${INK}"/>
    <path d="M-2,-12 l-4,-6 M2,-12 l4,-6" stroke="${INK}" stroke-width="1.8" stroke-linecap="round"/>
    <path d="M0,-6 v16" stroke="${INK}" stroke-width="1.4"/></g>`; }

// the bot reviewer: round (it is a model) with long ears and no hat
function rabbit(x,y,t,o={}){ const s=o.s||1, bob=Math.sin(t*3+1)*1.2, ear=Math.sin(t*2.5)*5;
  return `<g transform="translate(${r2(x)},${r2(y)}) scale(${s})">
   <ellipse cx="0" cy="34" rx="15" ry="4" fill="rgba(21,23,28,.15)"/>
   <path d="M-6,22 l-2,12 M6,22 l2,12" stroke="${INK}" stroke-width="3" stroke-linecap="round"/>
   <g transform="translate(0,${r2(bob)})">
    <g transform="rotate(${r2(-8+ear*0.4)} -7 -8)"><ellipse cx="-7" cy="-26" rx="6" ry="17" fill="#fff" stroke="${INK}" stroke-width="2.4"/><ellipse cx="-7" cy="-26" rx="2.6" ry="11" fill="${GREY}"/></g>
    <g transform="rotate(${r2(10-ear*0.4)} 7 -8)"><ellipse cx="7" cy="-26" rx="6" ry="17" fill="#fff" stroke="${INK}" stroke-width="2.4"/><ellipse cx="7" cy="-26" rx="2.6" ry="11" fill="${GREY}"/></g>
    <ellipse cx="0" cy="6" rx="17" ry="18" fill="#fff" stroke="${INK}" stroke-width="2.6"/>
    <circle cx="-5" cy="-2" r="2.3" fill="${INK}"/><circle cx="5" cy="-2" r="2.3" fill="${INK}"/>
    <path d="M-2,4 l2,2 l2,-2" fill="${MID}" stroke="${INK}" stroke-width="1.4"/>
    <path d="M0,6 v3 M-3,10 q3,2 6,0" fill="none" stroke="${INK}" stroke-width="1.4"/>
    <path d="M-13,6 q-6,6 -3,12 M13,6 q6,6 3,12" stroke="${INK}" stroke-width="2.4" fill="none" stroke-linecap="round"/>
   </g></g>`; }

// a human: not round, not square — a person with hair and a sweater (the one who reads and merges)
function human(x,y,t,o={}){ const s=o.s||1, bob=Math.sin(t*2)*0.8, cheer=o.cheer;
  return `<g transform="translate(${r2(x)},${r2(y)}) scale(${s})">
   <ellipse cx="0" cy="44" rx="17" ry="4" fill="rgba(21,23,28,.15)"/>
   <path d="M-6,26 l-2,18 M6,26 l2,18" stroke="${INK}" stroke-width="3.6" stroke-linecap="round"/>
   <g transform="translate(0,${r2(bob)})">
    <path d="M-15,28 q0,-26 15,-26 q15,0 15,26 z" fill="${MID}" stroke="${INK}" stroke-width="2.6"/>
    ${cheer?`<path d="M-13,10 l-10,-14 M13,10 l10,-14" stroke="${INK}" stroke-width="3" stroke-linecap="round"/>`
           :`<path d="M-13,10 q-7,8 -2,14 M13,10 q7,8 2,14" stroke="${INK}" stroke-width="3" fill="none" stroke-linecap="round"/>`}
    <circle cx="0" cy="-12" r="13" fill="#F1DCC6" stroke="${INK}" stroke-width="2.6"/>
    <path d="M-13,-14 q2,-14 14,-13 q12,0 12,12 q-8,-6 -14,-6 q-6,1 -12,7 z" fill="${INK}"/>
    <circle cx="-4.5" cy="-11" r="1.9" fill="${INK}"/><circle cx="4.5" cy="-11" r="1.9" fill="${INK}"/>
    <path d="M-3,-5 q3,3 6,0" fill="none" stroke="${INK}" stroke-width="1.6"/>
   </g></g>`; }

// a door with a sign
function door(x,y,w,h,label,open=0){
  return `<g transform="translate(${r2(x)},${r2(y)})">
   <rect x="-8" y="-8" width="${w+16}" height="${h+8}" rx="4" fill="${INK}"/>
   <rect x="0" y="0" width="${w}" height="${h}" fill="#2B2F37" stroke="${INK}" stroke-width="2.4"/>
   <rect x="0" y="0" width="${r2(w*(1-open*0.7))}" height="${h}" fill="#5F6672" stroke="${INK}" stroke-width="2.4"/>
   <circle cx="${r2(w*(1-open*0.7))-9}" cy="${h*0.55}" r="3.4" fill="#fff" stroke="${INK}" stroke-width="1.6"/>
   <rect x="${w/2-34}" y="-34" width="68" height="24" rx="4" fill="#fff" stroke="${INK}" stroke-width="2.4"/>
   <text x="${w/2}" y="-17" text-anchor="middle" font-size="15" font-weight="900" font-family="${M}" fill="${INK}">${label}</text></g>`; }

// a row of book spines: n books (the first one is the index)
function books(x,y,n){ let g=''; const cols=[PALE,'#fff',GREY,'#fff']; let cx=0;
  for(let i=0;i<n;i++){ const w=11+((i*5)%3), h=38+((i*7)%10); g+=`<rect x="${cx}" y="${-h}" width="${w}" height="${h}" rx="1.5" fill="${cols[i%cols.length]}" stroke="${INK}" stroke-width="1.8"/><path d="M${cx+3},${-h+8} h${w-6}" stroke="${INK}" stroke-width="1.2" opacity=".5"/>`; cx+=w+2; }
  return `<g transform="translate(${r2(x)},${r2(y)})">${g}<rect x="-4" y="0" width="${cx+6}" height="5" fill="${WOOD}" stroke="${INK}" stroke-width="1.8"/></g>`; }

// a grid of pinned habit cards (memory), n cards
function pinboard(x,y,cols,n,o={}){ let g=''; const w=o.w||14, h=o.h||11, gap=o.gap||3;
  for(let i=0;i<n;i++){ const c=i%cols, r=Math.floor(i/cols); const rot=((i*37)%7)-3;
    g+=`<g transform="translate(${c*(w+gap)},${r*(h+gap)}) rotate(${rot} ${w/2} ${h/2})"><rect width="${w}" height="${h}" rx="1" fill="#fff" stroke="${INK}" stroke-width="1.3"/><path d="M3,${h*0.45} h${w-6}" stroke="${INK}" stroke-width="1" opacity=".5"/><circle cx="${w/2}" cy="1.6" r="1.6" fill="${INK}"/></g>`; }
  return `<g transform="translate(${r2(x)},${r2(y)})">${g}</g>`; }

// a recipe card (skill)
function recipe(x,y,title,rot=0,W=152){ return `<g transform="translate(${r2(x)},${r2(y)}) rotate(${rot})">
  <rect x="3" y="3" width="${W}" height="22" rx="3" fill="${INK}"/><rect width="${W}" height="22" rx="3" fill="#fff" stroke="${INK}" stroke-width="2"/>
  <rect width="6" height="22" rx="2" fill="${INK}" stroke="${INK}" stroke-width="1.6"/>
  <text x="12" y="15.5" font-size="10.5" font-weight="800" font-family="${M}" fill="${INK}">${title}</text></g>`; }

// a numbered pin (one of the four checks)
function pin(x,y,n,s=1){ return `<g transform="translate(${r2(x)},${r2(y)}) scale(${s})">
  <circle cx="2.5" cy="2.5" r="14" fill="${INK}"/><circle r="14" fill="#fff" stroke="${INK}" stroke-width="2.6"/>
  <text y="6" text-anchor="middle" font-size="17" font-weight="900" font-family="${F}" fill="${INK}">${n}</text></g>`; }

// a name tag under a character (mono, the repo's own file name)
function tag(x,y,name,o={}){ const w=o.w||(name.length*7.4+14);
  return `<g transform="translate(${r2(x-w/2)},${r2(y)})"><rect width="${w}" height="18" rx="4" fill="${o.fill||'#fff'}" stroke="${INK}" stroke-width="1.8"/>
   <text x="${w/2}" y="13" text-anchor="middle" font-size="11.5" font-weight="800" font-family="${M}" fill="${INK}">${name}</text></g>`; }

window.SKIT={prop,agent,bug,rabbit,human,door,books,pinboard,recipe,pin,tag,F,M};
})();
