document.addEventListener('DOMContentLoaded', ()=>{
  const modal = document.getElementById('proj-modal');
  const modalImg = document.getElementById('proj-img');
  const modalTitle = document.getElementById('proj-title');
  const modalDesc = document.getElementById('proj-desc');
  const closeBtn = document.getElementById('proj-close');

  document.querySelectorAll('.card').forEach(card=>{
    card.addEventListener('click', ()=>{
      const img = card.dataset.img || card.querySelector('img').src;
      const title = card.dataset.title || card.querySelector('.card-title').innerText;
      const desc = card.dataset.desc || '';
      modalImg.src = img;
      modalImg.alt = title;
      modalTitle.textContent = title;
      modalDesc.textContent = desc;
  // populate action links (asm/pdf) if present
  const asm = card.dataset.asm;
  const doc = card.dataset.doc;
  const onlyDoc = card.dataset.onlyDoc === 'true';
  const demoBtn = document.getElementById('proj-demo');
  const repoBtn = document.getElementById('proj-repo');
  if(onlyDoc){
    // show single download button
    demoBtn.style.display = 'none';
    repoBtn.style.display = 'inline-block';
    if(doc){ repoBtn.href = encodeURI(doc); repoBtn.textContent = 'Download document'; repoBtn.setAttribute('download',''); repoBtn.target = '';} else { repoBtn.href = '#'; repoBtn.textContent = 'Download document'; }
  } else {
    demoBtn.style.display = '';
    repoBtn.style.display = '';
    if(asm){ demoBtn.href = encodeURI(asm); demoBtn.textContent = 'Download ASM'; demoBtn.setAttribute('download',''); } else { demoBtn.href = '#'; demoBtn.textContent = 'Live Demo'; demoBtn.removeAttribute('download'); }
    if(doc){ repoBtn.href = encodeURI(doc); repoBtn.textContent = 'Open Document'; repoBtn.target = '_blank'; } else { repoBtn.href = '#'; repoBtn.textContent = 'Repository'; repoBtn.target = ''; }
  }
  modal.setAttribute('aria-hidden','false');
      document.body.style.overflow='hidden';
    });
  });

  function closeModal(){ modal.setAttribute('aria-hidden','true'); document.body.style.overflow=''; }
  closeBtn.addEventListener('click', closeModal);
  modal.addEventListener('click', (e)=>{ if(e.target===modal) closeModal(); });
  document.addEventListener('keydown', (e)=>{ if(e.key==='Escape') closeModal(); });
});
