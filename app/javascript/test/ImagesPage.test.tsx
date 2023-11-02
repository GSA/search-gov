import '@testing-library/jest-dom';
import { render } from '@testing-library/react';
import React from 'react';

import { ImagesPage } from '../components/Results/ImagesPage/ImagesPage';

describe('Images Page component', () => {
  const images = [
  {
    altText: '18F: Digital service delivery | Avoiding cloudfall: A systematic ...',
    url: 'https://18f.gsa.gov/2015/06/22/avoiding-cloudfall/',
    thumbnailUrl: 'https://plus.unsplash.com/premium_photo-1664303499312-917c50e4047b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8dG9ybmFkb3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=800&q=60',
    image: true
  },
  {
    altText: 'Heritage Tourism | GSA',
    url: 'https://www.gsa.gov/real-estate/historic-preservation/explore-historic-buildings/heritage-tourism',
    thumbnailUrl: 'https://plus.unsplash.com/premium_photo-1664303499312-917c50e4047b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8dG9ybmFkb3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=800&q=60',
    image: true
  }
]
  it('renders images component', () => {
    render(
      <ImagesPage images={images} />
    );
  });

  it('shows image title and src', () => {
    render(
      <ImagesPage images={images} />
    );
    const img = Array.from(document.getElementsByClassName('result-image')).pop() as HTMLImageElement;
    expect(img).toHaveAttribute('src', 'https://plus.unsplash.com/premium_photo-1664303499312-917c50e4047b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8dG9ybmFkb3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=800&q=60');
    expect(img).toHaveAttribute('alt', 'Heritage Tourism | GSA');
  });
});
