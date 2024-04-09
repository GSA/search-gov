import '@testing-library/jest-dom';
import { render, fireEvent } from '@testing-library/react';
import React from 'react';
import { enableFetchMocks } from 'jest-fetch-mock';
enableFetchMocks();

import { ImagesPage } from '../components/Results/ImagesPage/ImagesPage';

describe('Images Page component', () => {
  const headers = {
    Accept: 'application/json',
    'Content-Type': 'application/json'
  };

  global.fetch = jest.fn(() =>
    Promise.resolve({
      json: () => Promise.resolve({})
    })
  ) as jest.Mock;

  const images = [
    {
      altText: '18F: Digital service delivery | Avoiding cloudfall: A systematic ...',
      url: 'https://18f.gsa.gov/2015/06/22/avoiding-cloudfall/',
      thumbnailUrl: 'https://plus.unsplash.com/premium_photo-1664303499312-917c50e4047b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8dG9ybmFkb3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=800&q=60',
      image: true
    },
    {
      altText: 'Heritage Tourism',
      url: 'https://www.gsa.gov/real-estate/historic-preservation/explore-historic-buildings/heritage-tourism',
      thumbnailUrl: 'https://plus.unsplash.com/premium_photo-1664303499312-917c50e4047b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8dG9ybmFkb3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=800&q=60',
      image: true
    }
  ];
  it('renders images component', () => {
    render(
      <ImagesPage images={images} affiliate={'searchgov'} query={'test query'} vertical={'IMAG'} />
    );

    const image = Array.from(document.getElementsByClassName('result-image')).pop() as HTMLImageElement;
    fireEvent.click(image);
    /* eslint-disable camelcase */
    const clickBody = {
      affiliate: 'searchgov',
      url: 'https://www.gsa.gov/real-estate/historic-preservation/explore-historic-buildings/heritage-tourism',
      module_code: 'IMAG',
      position: 2,
      query: 'test query',
      vertical: 'IMAG'
    };
    /* eslint-enable camelcase */
    expect(fetch).toHaveBeenCalledWith('/clicked', {
      body: JSON.stringify(clickBody),
      headers,
      method: 'POST',
      mode: 'cors'
    });
    expect(fetch).toHaveBeenCalledTimes(1);
  });

  it('shows image title and src', () => {
    render(
      <ImagesPage images={images} affiliate={'searchgov'} query={'test query'} vertical={'IMAG'}/>
    );
    const img = Array.from(document.getElementsByClassName('result-image')).pop() as HTMLImageElement;
    expect(img).toHaveAttribute('src', 'https://plus.unsplash.com/premium_photo-1664303499312-917c50e4047b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8dG9ybmFkb3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=800&q=60');
    expect(img).toHaveAttribute('alt', 'Heritage Tourism');
  });
});
