import '@testing-library/jest-dom';
import { render } from '@testing-library/react';
import React from 'react';

import { ImagesPage } from '../components/Results/ImagesPage/ImagesPage';

describe('Images Page component', () => {
  it('renders images component', () => {
    render(
      <ImagesPage />
    );
  });

  it('shows image title and src', () => {
    render(
      <ImagesPage />
    );
    const img = Array.from(document.getElementsByClassName('result-image')).pop() as HTMLImageElement;
    expect(img).toHaveAttribute('src', 'https://images.unsplash.com/photo-1603398938378-e54eab446dde?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8bWVkaWNhbHxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=800&q=60');
    expect(img).toHaveAttribute('alt', 'title 5');
  });
});
