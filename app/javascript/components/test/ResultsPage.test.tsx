import '@testing-library/jest-dom';
import { render, screen } from '@testing-library/react';
import React from 'react';
import ResultsPage from '../ResultsPage';

describe('App tests', () => {
    it('should contains the heading 1', () => {
        render(<ResultsPage params="foo" results="[1, 2, 3]" />);
        const heading = screen.getByText(/Greeting/i);
        expect(heading).toBeInTheDocument()
    });
});