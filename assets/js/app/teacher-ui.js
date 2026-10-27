/* Teacher dashboard enhancements: icon navigation and consistent page chrome. */
(function(){
  const NAV = {
    Dashboard: 'home', Courses: 'book-open', Assignments: 'pencil', Tests: 'target',
    Gradebook: 'bookmark', Leaderboard: 'trophy', Calendar: 'calendar', Settings: 'settings'
  };

  function enhance(){
    document.body.classList.add('teacher-page');
    const nav = document.querySelector('.dash-nav');
    if(!nav) return;
    if(!nav.querySelector('a[href="teacher-courses.html"]')){
      const courses = document.createElement('a');
      courses.href = 'teacher-courses.html';
      courses.innerHTML = '<span class="n-label">Courses</span>';
      const dashboard = Array.from(nav.children).find(item => item.textContent.trim() === 'Dashboard');
      if(dashboard) dashboard.insertAdjacentElement('afterend', courses);
      else nav.appendChild(courses);
    }
    if(!nav.querySelector('a[href="teacher-leaderboard.html"]')){
      const leaderboard = document.createElement('a');
      leaderboard.href = 'teacher-leaderboard.html';
      leaderboard.innerHTML = '<span class="n-label">Leaderboard</span>';
      const gradebook = Array.from(nav.children).find(item => item.textContent.trim() === 'Gradebook');
      if(gradebook) gradebook.insertAdjacentElement('afterend', leaderboard);
      else nav.appendChild(leaderboard);
    }
    nav.querySelectorAll('a').forEach(link => {
      const label = link.querySelector('.n-label');
      const name = label ? label.textContent.trim() : link.textContent.trim();
      if(!label || link.querySelector('.n-icon')) return;
      const iconName = NAV[name] || 'bookmark';
      label.insertAdjacentHTML('beforebegin', '<span class="n-icon">' + icon(iconName) + '</span>');
      if(location.pathname.endsWith(link.getAttribute('href'))) link.classList.add('active');
    });
  }
  if(document.readyState === 'loading') document.addEventListener('DOMContentLoaded', enhance);
  else enhance();
})();
