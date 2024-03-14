/* eslint-disable camelcase */

import '@testing-library/jest-dom';
import { fireEvent, render, screen } from '@testing-library/react';
import React from 'react';
import { enableFetchMocks } from 'jest-fetch-mock';
enableFetchMocks();

import { Video } from '../components/Results/Videos/Video';

describe('Videos component', () => {
  const headers = {
    Accept: 'application/json',
    'Content-Type': 'application/json'
  };

  global.fetch = jest.fn(() =>
    Promise.resolve({
      json: () => Promise.resolve({})
    })
  ) as jest.Mock;

  const video = {
    affiliate: 'test_affiliate',
    description: 'string',
    duration: '2:50',
    link: 'string',
    position: 1,
    publishedAt: '2 days ago',
    query: 'video',
    title: 'image title',
    vertical: 'web',
    youtubeThumbnailUrl: 'https://plus.unsplash.com/premium_photo-1664303499312-917c50e4047b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8dG9ybmFkb3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=800&q=60'
  };
  
  it('renders videos component', () => {
    render(
      <Video {...video}/>
    );
  });

  it('shows video image and title', () => {
    render(
      <Video {...video}/>
    );
    const img = Array.from(document.getElementsByClassName('result-image')).pop() as HTMLImageElement;
    expect(img).toHaveAttribute('src', 'https://plus.unsplash.com/premium_photo-1664303499312-917c50e4047b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8dG9ybmFkb3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=800&q=60');
    expect(img).toHaveAttribute('alt', 'image title');
  });

  it('calls fetch with correct video module click data', () => {
    render(<Video {...video}/>);

    const link = screen.getByText(/image title/i);
    fireEvent.click(link);
    const clickBody = {
      affiliate: 'test_affiliate',
      url: 'string',
      module_code: 'VIDS',
      position: 1,
      query: 'video',
      vertical: 'web'
    };

    expect(fetch).toHaveBeenCalledWith('/clicked', {
      body: JSON.stringify(clickBody),
      headers,
      method: 'POST',
      mode: 'cors'
    });
    expect(fetch).toHaveBeenCalledTimes(1);
  });
});

describe('Mobile view: Video component clicking the content div', () => {
  beforeAll(() => {
    window.innerWidth = 450;
  });

  const headers = {
    Accept: 'application/json',
    'Content-Type': 'application/json'
  };

  global.fetch = jest.fn(() =>
    Promise.resolve({
      json: () => Promise.resolve({})
    })
  ) as jest.Mock;

  const video = {
    affiliate: 'test_affiliate',
    description: 'My video description',
    duration: '2:50',
    link: 'string',
    position: 1,
    publishedAt: '2 days ago',
    query: 'video',
    title: 'image title',
    vertical: 'web',
    youtubeThumbnailUrl: 'https://plus.unsplash.com/premium_photo-1664303499312-917c50e4047b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8dG9ybmFkb3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=800&q=60'
  };

  it('calls fetch with correct video click data', () => {
    render(<Video {...video}/>);

    const desc = screen.getByText(/My video description/i);
    fireEvent.click(desc);
    const clickBody = {
      affiliate: 'test_affiliate',
      url: 'string',
      module_code: 'VIDS',
      position: 1,
      query: 'video',
      vertical: 'web'
    };

    expect(fetch).toHaveBeenCalledWith('/clicked', {
      body: JSON.stringify(clickBody),
      headers,
      method: 'POST',
      mode: 'cors'
    });
    expect(fetch).toHaveBeenCalledTimes(1);
  });
});
