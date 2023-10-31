import '@testing-library/jest-dom';
import { render } from '@testing-library/react';
import React from 'react';

import { Video } from '../components/Results/Videos/Video';

describe('Vidoes component', () => {
  const video = {
    link: 'string',
    title: 'image title',
    description: 'string',
    publishedAt: '2 days ago',
    youtubeThumbnailUrl: 'https://plus.unsplash.com/premium_photo-1664303499312-917c50e4047b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8dG9ybmFkb3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=800&q=60',
    duration: '2:50'
  }
  it('renders videos component', () => {
    render(
      <Video {...video}/>
    );
  });

  it('shows vidoe image and title', () => {
    render(
      <Video {...video}/>
    );
    const img = Array.from(document.getElementsByClassName('result-image')).pop() as HTMLImageElement;
    expect(img).toHaveAttribute('src', 'https://plus.unsplash.com/premium_photo-1664303499312-917c50e4047b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8dG9ybmFkb3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=800&q=60');
    expect(img).toHaveAttribute('alt', 'image title');
  });
});
