
export interface HeaderProps {
  title: string
  handleSearch(any): void
  toggleMobileNav(): void
  mobileNavOpen: boolean
  handleToggleNavDropdown(number): void
  navDropdownOpen: boolean[]
}
